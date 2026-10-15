#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Restores UE environment variables from a saved configuration.
.DESCRIPTION
    Applies saved variables to the user profile and the current PowerShell
    process. Invoke with & in the caller's process, not a separate pwsh process.
.PARAMETER ConfigPath
    Configuration file to restore. Defaults to environment.json in the current directory.
.EXAMPLE
    ./Restore-UEEnvironment.ps1
.EXAMPLE
    ./Restore-UEEnvironment.ps1 -ConfigPath ./environment.json
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$ConfigPath = (Join-Path (Get-Location) 'environment.json')
)

function Set-EnvironmentVariableUserAndSession {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [string]$Name,
        [Parameter(Mandatory = $true)] [string]$Value
    )

    $currentUserValue = [Environment]::GetEnvironmentVariable($Name, 'User')
    if ($currentUserValue -ne $Value) {
        [Environment]::SetEnvironmentVariable($Name, $Value, 'User')
        Write-Host "Set user env $Name to $Value"
    }
    else {
        Write-Host "User env $Name already set; skipping write"
    }

    $currentSessionValue = (Get-Item -Path "Env:$Name" -ErrorAction SilentlyContinue).Value
    if ($currentSessionValue -ne $Value) {
        Set-Item -Path "Env:$Name" -Value $Value
        Write-Host "Set session env $Name to $Value"
    }
    else {
        Write-Host "Session env $Name already set; skipping write"
    }
}

function Restore-EnvironmentVariables {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ConfigPath
    )

    if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) {
        $exception = [System.IO.FileNotFoundException]::new("Environment configuration not found at: $ConfigPath")
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
            $exception,
            'ConfigNotFound',
            [System.Management.Automation.ErrorCategory]::ObjectNotFound,
            $ConfigPath
        )
        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    Write-Host "Reading environment configuration from $ConfigPath..." -ForegroundColor Cyan
    $configData = Get-Content -LiteralPath $ConfigPath -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop

    Write-Host 'Applying environment variables to current user and session...' -ForegroundColor Cyan
    foreach ($key in $configData.PSObject.Properties.Name) {
        Set-EnvironmentVariableUserAndSession -Name $key -Value ([string]$configData.$key)
    }
    Write-Host 'Environment variables restored successfully.' -ForegroundColor Green
}

if ($MyInvocation.InvocationName -ne '.') {
    $ErrorActionPreference = 'Stop'
    Restore-EnvironmentVariables -ConfigPath $ConfigPath
}