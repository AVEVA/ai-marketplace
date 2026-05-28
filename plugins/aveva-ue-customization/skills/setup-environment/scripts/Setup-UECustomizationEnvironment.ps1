<#
.SYNOPSIS
    Sets up the UE Customization environment structure and configuration.

.DESCRIPTION
    This script creates the necessary directory structure, unpacks UE MSIX files,
    and configures environment variables for AVEVA Unified Engineering add-in development.

.PARAMETER ReuseEnvironment
    If specified and environment.json exists, skips unpacking and reuses the existing environment.
    If environment.json doesn't exist, performs full setup regardless.

.EXAMPLE
    .\Setup-UECustomizationEnvironment.ps1

.EXAMPLE
    .\Setup-UECustomizationEnvironment.ps1 -ReuseEnvironment

.EXAMPLE
    .\Setup-UECustomizationEnvironment.ps1 -Verbose

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [switch]$ReuseEnvironment
)

begin {
    $ErrorActionPreference = "Stop"
    # Use current workspace directory for environment setup
    $CustomizationRootDir = Get-Location
    # Reference helper module from plugin helpers folder (3 levels up to plugin root)
    $modulePath = Join-Path -Path $PSScriptRoot -ChildPath "..\..\..\helpers\UECustomizationFunctions.psm1"
    Import-Module -Name $modulePath -Force -ErrorAction Stop
}

process {
    $addinsFolder = Join-Path -Path $CustomizationRootDir -ChildPath "addins\"
    $pmlLibFolder = Join-Path -Path $CustomizationRootDir -ChildPath "pmllib\"
    $sourceFolder = Join-Path -Path $CustomizationRootDir -ChildPath "source\"
    $configPath = Join-Path -Path $CustomizationRootDir -ChildPath "environment.json"

    # Setup based on mode
    if ($ReuseEnvironment) {
        Write-Host "Reusing existing environment - will skip time-consuming unpack if possible..." -ForegroundColor Cyan
        $latestUnpackPath = Invoke-UEUnpack -ReuseExisting
        
        if (Test-Path $configPath) {
            Restore-EnvironmentVariables -ConfigPath $configPath
        }
    }
    else {
        Clear-UECustomizationEnvironment
        $latestUnpackPath = Invoke-UEUnpack
    }

    Initialize-DirectoryStructure -AddinsFolder $addinsFolder -PmlLibFolder $pmlLibFolder -SourceFolder $sourceFolder
    Set-EnvironmentConfiguration -ConfigPath $configPath -AddinsFolder $addinsFolder -PmlLibFolder $pmlLibFolder -UnpackPath $latestUnpackPath
    Install-UEFiles -UnpackPath $latestUnpackPath -AddinsFolder $addinsFolder -SkipExisting:$ReuseEnvironment

    Write-Host "Finished." -ForegroundColor Green
}

end {
}
