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

function Get-VersionArray {
    <#
    .SYNOPSIS
        Parses a version string into an array of integers.

    .DESCRIPTION
        Extracts numeric parts from a version string and converts them to integers.
        Returns an empty array if parsing fails.

    .PARAMETER Name
        The version string to parse (e.g., "1.2.3" or "v1.2.3.4").

    .OUTPUTS
        System.Int32[]
        Array of integers representing version parts.

    .EXAMPLE
        Get-VersionArray -Name "1.2.3"
        Returns: @(1, 2, 3)
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    try {
        $parts = $Name -split "[^0-9]+" | Where-Object { $_ -ne "" }
        Write-Output @($parts | ForEach-Object { [int]$_ })
    }
    catch {
        Write-Output @()
    }
}

function Invoke-UEUnpack {
    <#
    .SYNOPSIS
        Runs UE unpack tool and returns the latest unpacked version folder path.

    .DESCRIPTION
        Validates that the UE CLI is available, executes the UE -tool:unpack command,
        and locates the latest unpacked version folder using semantic version sorting.
        If ReuseExisting is specified, attempts to reuse the UNIFIED_ENGINEERING_REFERENCE_PATH
        environment variable instead of unpacking.

    .PARAMETER ReuseExisting
        If specified, attempts to reuse the existing UNIFIED_ENGINEERING_REFERENCE_PATH
        environment variable instead of running unpack. If the variable doesn't exist
        or is invalid, falls back to performing a full unpack.

    .OUTPUTS
        System.String
        The full path to the latest unpacked UE version folder.

    .EXAMPLE
        Invoke-UEUnpack

    .EXAMPLE
        Invoke-UEUnpack -ReuseExisting

    .NOTES
        Requires AVEVA Unified Engineering to be installed and accessible via the UE command.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [switch]$ReuseExisting
    )

    # If ReuseExisting is specified, try to get the path from environment variable
    if ($ReuseExisting) {
        $existingPath = [System.Environment]::GetEnvironmentVariable('UNIFIED_ENGINEERING_REFERENCE_PATH', 'User')
        if ($existingPath -and (Test-Path -Path $existingPath)) {
            Write-Host "Reusing existing unpack path from UNIFIED_ENGINEERING_REFERENCE_PATH..." -ForegroundColor Cyan
            Write-Host "Unpacked folder: $existingPath" -ForegroundColor Green
            Write-Host "Skipping unpack operation." -ForegroundColor Yellow
            Write-Output $existingPath
            return
        }
        else {
            Write-Host "UNIFIED_ENGINEERING_REFERENCE_PATH not found or invalid." -ForegroundColor Yellow
            Write-Host "Proceeding with full unpack..." -ForegroundColor Cyan
        }
    }

    Write-Verbose "Checking for UE installation..."
    try {
        $null = Get-Command UE -ErrorAction Stop
    }
    catch {
        $exception = [System.InvalidOperationException]::new("UE not found. Please install AVEVA Unified Engineering.")
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
            $exception,
            'UENotFound',
            [System.Management.Automation.ErrorCategory]::NotInstalled,
            'UE'
        )
        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    Write-Host "Running 'UE -tool:unpack' to extract MSIX..." -ForegroundColor Cyan
    try {
        Write-Host "Executing: UE -tool:unpack" -ForegroundColor DarkGray
        & UE -tool:unpack | Out-Null
    }
    catch {
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
            $_.Exception,
            'UEUnpackFailed',
            [System.Management.Automation.ErrorCategory]::NotSpecified,
            'UE'
        )
        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    $unpackBase = "C:\Users\Public\Documents\AVEVA\Unpack\AVEVA.UnifiedEngineering"
    if (-not (Test-Path -Path $unpackBase)) {
        $exception = [System.IO.DirectoryNotFoundException]::new("Expected unpack base folder not found: $unpackBase")
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
            $exception,
            'UnpackBaseNotFound',
            [System.Management.Automation.ErrorCategory]::ObjectNotFound,
            $unpackBase
        )
        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    Write-Host "Locating latest unpacked version under $unpackBase..." -ForegroundColor Cyan
    $dirs = Get-ChildItem -Path $unpackBase -Directory -ErrorAction SilentlyContinue
    if (-not $dirs -or $dirs.Count -eq 0) {
        $exception = [System.IO.DirectoryNotFoundException]::new("No versioned directories found under $unpackBase")
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
            $exception,
            'NoVersionedDirectories',
            [System.Management.Automation.ErrorCategory]::ObjectNotFound,
            $unpackBase
        )
        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    $dirsWithVersion = $dirs | ForEach-Object {
        [PSCustomObject]@{
            Name          = $_.Name
            Path          = $_.FullName
            VersionParts  = Get-VersionArray -Name $_.Name
            LastWriteTime = $_.LastWriteTime
        }
    }

    if ($dirsWithVersion | Where-Object { $_.VersionParts.Count -gt 0 }) {
        $latest = $dirsWithVersion | Sort-Object -Property @{
            Expression = { $_.VersionParts[0] }
            Descending = $true
        }, @{
            Expression = { $_.VersionParts[1] }
            Descending = $true
        }, @{
            Expression = { $_.VersionParts[2] }
            Descending = $true
        } -ErrorAction SilentlyContinue | Select-Object -First 1
    }
    else {
        $latest = $dirsWithVersion | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1
    }

    if (-not $latest) {
        $exception = [System.InvalidOperationException]::new("Unable to determine latest unpacked version folder.")
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
            $exception,
            'LatestVersionNotFound',
            [System.Management.Automation.ErrorCategory]::InvalidResult,
            $unpackBase
        )
        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }
    Write-Host "Latest unpacked folder: $($latest.Path)" -ForegroundColor Green

    Write-Output $latest.Path
}

function Set-EnvironmentConfiguration {
    <#
    .SYNOPSIS
        Creates and applies environment configuration.

    .DESCRIPTION
        Builds the environment configuration data structure, saves it to JSON,
        and applies the variables to both the user scope (persisted) and
        the current PowerShell session.

    .PARAMETER ConfigPath
        The full path where the environment.json configuration file will be saved.

    .PARAMETER AddinsFolder
        The path to the addins folder.

    .PARAMETER PmlLibFolder
        The path to the pmllib folder.

    .PARAMETER UnpackPath
        The path to the unpacked UE binaries.

    .OUTPUTS
        System.Collections.Specialized.OrderedDictionary
        Returns the configuration data that was created and applied.

    .EXAMPLE
        Set-EnvironmentConfiguration -ConfigPath "C:\config\environment.json" -AddinsFolder "C:\addins" -PmlLibFolder "C:\pmllib" -UnpackPath "C:\binaries"

    .NOTES
        This function persists environment variables to the user profile registry.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ConfigPath,

        [Parameter(Mandatory = $true)]
        [string]$AddinsFolder,

        [Parameter(Mandatory = $true)]
        [string]$PmlLibFolder,

        [Parameter(Mandatory = $true)]
        [string]$UnpackPath

    )

    $configData = [ordered]@{
        CAF_ADDINS_PATH                    = $AddinsFolder
        CAF_UIC_PATH                       = $AddinsFolder
        CUSTOM_PMLLIB                      = $PmlLibFolder
        UNIFIED_ENGINEERING_REFERENCE_PATH = $UnpackPath
    }

    if ($PSCmdlet.ShouldProcess($ConfigPath, 'Write environment configuration and apply environment variables')) {
        Write-Host "Writing environment summary to $ConfigPath..." -ForegroundColor Cyan
        $configData | ConvertTo-Json | Set-Content -Path $ConfigPath -Encoding utf8

        & (Join-Path $PSScriptRoot '..' '..' 'restore-environment' 'scripts' 'Restore-UEEnvironment.ps1') -ConfigPath $configPath
    }

    Write-Output $configData
}

function Initialize-DirectoryStructure {
    <#
    .SYNOPSIS
        Creates the customization environment directory structure.

    .DESCRIPTION
        Creates the addins, pmllib, and source directories required for the
        UE customization environment.

    .PARAMETER AddinsFolder
        The path to the addins folder to create.

    .PARAMETER PmlLibFolder
        The path to the pmllib folder to create.

    .PARAMETER SourceFolder
        The path to the source folder to create.

    .EXAMPLE
        Initialize-DirectoryStructure -AddinsFolder "C:\addins" -PmlLibFolder "C:\pmllib" -SourceFolder "C:\source"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$AddinsFolder,

        [Parameter(Mandatory = $true)]
        [string]$PmlLibFolder,

        [Parameter(Mandatory = $true)]
        [string]$SourceFolder
    )

    Write-Host "Setting up customization environment..." -ForegroundColor Cyan
    Write-Host "Creating directory at $AddinsFolder..." -ForegroundColor Cyan
    New-Item -Path $AddinsFolder -ItemType Directory -Force | Out-Null
    
    # Create pmllib directory structure
    Write-Host "Creating directory at $PmlLibFolder..." -ForegroundColor Cyan
    New-Item -Path $PmlLibFolder -ItemType Directory -Force | Out-Null
    Write-Host "Creating PML library subdirectories..." -ForegroundColor Cyan
    New-Item -Path (Join-Path -Path $PmlLibFolder -ChildPath "forms") -ItemType Directory -Force | Out-Null
    New-Item -Path (Join-Path -Path $PmlLibFolder -ChildPath "functions") -ItemType Directory -Force | Out-Null
    New-Item -Path (Join-Path -Path $PmlLibFolder -ChildPath "objects") -ItemType Directory -Force | Out-Null
    
    # Create source directory for add-in projects
    Write-Host "Creating directory at $SourceFolder..." -ForegroundColor Cyan
    New-Item -Path $SourceFolder -ItemType Directory -Force | Out-Null
}

function Install-UEConfiguration {
    <#
    .SYNOPSIS
        Copies configuration files from unpacked UE content.

    .DESCRIPTION
        Locates XML configuration files matching *Addins.xml or *Customization*.xml
        in the unpacked UE content and copies them to the addins folder.

    .PARAMETER UnpackPath
        The path to the unpacked UE binaries.

    .PARAMETER AddinsFolder
        The destination path for configuration files.

    .PARAMETER SkipExisting
        If specified, skips copying if files already exist to preserve customizations.

    .EXAMPLE
        Install-UEConfiguration -UnpackPath "C:\UE\Unpack" -AddinsFolder "C:\addins"

    .EXAMPLE
        Install-UEConfiguration -UnpackPath "C:\UE\Unpack" -AddinsFolder "C:\addins" -SkipExisting
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$UnpackPath,

        [Parameter(Mandatory = $true)]
        [string]$AddinsFolder,

        [Parameter(Mandatory = $false)]
        [switch]$SkipExisting
    )

    Write-Host "Copying configuration files to addins folder..." -ForegroundColor Cyan
    
    # Find all XML files matching *Addins.xml or *Customization*.xml patterns
    $addinsFiles = Get-ChildItem -Path $UnpackPath -Recurse -Filter "*Addins.xml" -File -ErrorAction SilentlyContinue
    $customizationFiles = Get-ChildItem -Path $UnpackPath -Recurse -Filter "*Customization.xml" -File -ErrorAction SilentlyContinue
    
    $allConfigFiles = @($addinsFiles) + @($customizationFiles)
    
    if ($allConfigFiles.Count -eq 0) {
        Write-Warning "No configuration files matching *Addins.xml or *Customization.xml found in $UnpackPath"
    }
    else {
        $copiedCount = 0
        $skippedCount = 0
        foreach ($configFile in $allConfigFiles) {
            $destination = Join-Path -Path $AddinsFolder -ChildPath $configFile.Name
            if ($SkipExisting -and (Test-Path $destination)) {
                Write-Verbose "Skipped (already exists): $($configFile.Name)"
                $skippedCount++
            }
            else {
                Copy-Item -Path $configFile.FullName -Destination $destination -Force
                Write-Verbose "Copied: $($configFile.Name)"
                $copiedCount++
            }
        }
        if ($copiedCount -gt 0) {
            Write-Host "Copied $copiedCount configuration file(s) successfully." -ForegroundColor Green
        }
        if ($skippedCount -gt 0) {
            Write-Host "Skipped $skippedCount existing configuration file(s) to preserve customizations." -ForegroundColor Yellow
        }
    }
}

function Initialize-UECustomizationEnvironment {
    [CmdletBinding()]
    param (
        [switch]$ReuseEnvironment
    )

    $ErrorActionPreference = "Stop"
    $CustomizationRootDir = Get-Location
    $addinsFolder = Join-Path -Path $CustomizationRootDir -ChildPath "addins\"
    $pmlLibFolder = Join-Path -Path $CustomizationRootDir -ChildPath "pmllib\"
    $sourceFolder = Join-Path -Path $CustomizationRootDir -ChildPath "source\"
    $configPath = Join-Path -Path $CustomizationRootDir -ChildPath "environment.json"
    if ($ReuseEnvironment) {
        Write-Host "Reusing existing environment - will skip time-consuming unpack if possible..." -ForegroundColor Cyan
        $latestUnpackPath = Invoke-UEUnpack -ReuseExisting
        
        if (Test-Path $configPath) {
            & (Join-Path $PSScriptRoot '..' '..' 'restore-environment' 'scripts' 'Restore-UEEnvironment.ps1') -ConfigPath $configPath
        }
    }
    else {
        & (Join-Path $PSScriptRoot '..' '..' 'clear-environment' 'scripts' 'Clear-UECustomizationEnvironment.ps1')
        $latestUnpackPath = Invoke-UEUnpack
    }
    Initialize-DirectoryStructure -AddinsFolder $addinsFolder -PmlLibFolder $pmlLibFolder -SourceFolder $sourceFolder
    Set-EnvironmentConfiguration -ConfigPath $configPath -AddinsFolder $addinsFolder -PmlLibFolder $pmlLibFolder -UnpackPath $latestUnpackPath
    Install-UEConfiguration -UnpackPath $latestUnpackPath -AddinsFolder $addinsFolder -SkipExisting:$ReuseEnvironment
    Write-Host "Finished." -ForegroundColor Green
}

if ($MyInvocation.InvocationName -ne '.') {
    Initialize-UECustomizationEnvironment -ReuseEnvironment:$ReuseEnvironment
}
