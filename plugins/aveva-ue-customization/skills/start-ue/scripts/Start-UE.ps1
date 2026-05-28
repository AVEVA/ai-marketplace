<#
.SYNOPSIS
    Launches AVEVA Unified Engineering with restored environment variables.

.DESCRIPTION
    Restores the customization environment variables from environment.json
    and launches the AVEVA Unified Engineering application. Supports
    optionally passing through UE launch parameters for module, project,
    username, password, and mdb.

.EXAMPLE
    .\Start-UE.ps1
    Launches UE with the customization environment restored.

.EXAMPLE
    .\Start-UE.ps1 -Verbose
    Launches UE with verbose output showing environment restoration details.

.EXAMPLE
    .\Start-UE.ps1 -Module Engineering -Project MyProject -Username user1 -Mdb MyMdb
    Launches UE with the supplied module, project, username, and mdb values. Prompts securely for password.

.NOTES
    Requires that Setup-UECustomizationEnvironment.ps1 has been run previously
    to create the environment.json configuration file.
    Requires AVEVA Unified Engineering to be installed and accessible via the UE command.
#>

[CmdletBinding()]
param(
    [Parameter()]
    [Alias('md')]
    [string] $Module,

    [Parameter()]
    [Alias('proj','p')]
    [string] $Project,

    [Parameter()]
    [Alias('user','u')]
    [string] $Username,

    [Parameter()]
    [Alias('m')]
    [string] $Mdb
)

begin {
    $ErrorActionPreference = 'Stop'
    
    # Use current workspace directory to find environment configuration
    $CustomizationRootDir = Get-Location
    
    # Reference helper module from plugin helpers folder (3 levels up to plugin root)
    $modulePath = Join-Path -Path $PSScriptRoot -ChildPath "..\..\..\helpers\UECustomizationFunctions.psm1"
    Import-Module -Name $modulePath -Force -ErrorAction Stop
}

process {
    # Path to environment configuration
    $configPath = Join-Path -Path $CustomizationRootDir -ChildPath "environment.json"
    
    # Restore environment variables
    if (Test-Path -Path $configPath) {
        Restore-EnvironmentVariables -ConfigPath $configPath
    }
    else {
        Write-Warning "Environment configuration not found at: $configPath"
        Write-Warning "Please run Setup-UECustomizationEnvironment.ps1 first."
        Write-Host "`nAttempting to launch UE anyway..." -ForegroundColor Yellow
    }
    
    # Check if UE is available
    Write-Verbose "Checking for UE installation..."
    try {
        $null = Get-Command UE -ErrorAction Stop
    }
    catch {
        Write-Error "UE command not found. Please install AVEVA Unified Engineering and ensure it is in your PATH."
        exit 1
    }
    
    # Prompt for password securely if username is provided
    $Password = $null
    if ($Username) {
        Write-Host "Username specified. Please enter password:" -ForegroundColor Cyan
        $securePassword = Read-Host -AsSecureString
        
        # Convert SecureString to plain text for UE command line
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
        try {
            $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        }
        finally {
            # Clear the BSTR from memory immediately
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
        }
    }
    
    # Build optional UE launch arguments
    $ueArgs = @()
    if ($Module) { $ueArgs += "--module:$Module" }
    if ($Project) { $ueArgs += "--project:$Project" }
    if ($Username) { $ueArgs += "--username:$Username" }
    if ($Password) { $ueArgs += "--password:$Password" }
    if ($Mdb) { $ueArgs += "--mdb:$Mdb" }

    if ($ueArgs.Count -gt 0) {
        # Mask password in verbose output
        $safeArgs = $ueArgs | ForEach-Object {
            if ($_ -like '--password:*') { '--password:***' } else { $_ }
        }
        Write-Verbose "UE launch arguments: $($safeArgs -join ' ')"
    }
    
    # Launch UE
    Write-Host "`nLaunching AVEVA Unified Engineering..." -ForegroundColor Cyan
    
    try {
        & ue @ueArgs
        
        if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) {
            Write-Warning "UE exited with code $LASTEXITCODE"
            exit $LASTEXITCODE
        }
    }
    finally {
        # CRITICAL: Clear sensitive data from memory immediately
        if ($Password) {
            # Clear the password variable
            $Password = $null
            
            # Clear the ueArgs array (contains password)
            if ($ueArgs) {
                for ($i = 0; $i -lt $ueArgs.Count; $i++) {
                    if ($ueArgs[$i] -like '--password:*') {
                        $ueArgs[$i] = $null
                    }
                }
                $ueArgs = $null
            }
            
            # Force garbage collection to clear memory
            [GC]::Collect()
            [GC]::WaitForPendingFinalizers()
            [GC]::Collect()
        }
    }
    
    exit 0
}
