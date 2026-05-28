function Get-VersionParts {
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
        Get-VersionParts -Name "1.2.3"
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

function Find-RequiredFile {
    <#
    .SYNOPSIS
        Locates a required file within a directory tree.

    .DESCRIPTION
        Recursively searches for a file in the specified directory tree.
        Throws a terminating error if the file is not found.

    .PARAMETER RootPath
        The root directory path to search within.

    .PARAMETER FileName
        The name of the file to locate.

    .OUTPUTS
        System.String
        The full path to the located file.

    .EXAMPLE
        Find-RequiredFile -RootPath "C:\Temp" -FileName "config.xml"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$RootPath,

        [Parameter(Mandatory = $true)]
        [string]$FileName
    )

    Write-Verbose "Searching for $FileName in $RootPath..."
    $file = Get-ChildItem -Path $RootPath -Recurse -Filter $FileName -File -ErrorAction SilentlyContinue | Select-Object -First 1

    if (-not $file) {
        $exception = [System.IO.FileNotFoundException]::new("Required file '$FileName' not found in '$RootPath'")
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
            $exception,
            'RequiredFileNotFound',
            [System.Management.Automation.ErrorCategory]::ObjectNotFound,
            $FileName
        )
        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    Write-Verbose "Found: $($file.FullName)"
    Write-Output $file.FullName
}

function Set-EnvironmentVariableUserAndSession {
    <#
    .SYNOPSIS
        Sets an environment variable in both user and session scopes if it differs from current values.

    .DESCRIPTION
        Compares the provided value against current user and session environment variables.
        Only writes if values differ, avoiding redundant registry updates.

    .PARAMETER Name
        The name of the environment variable.

    .PARAMETER Value
        The value to set.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [string]$Name,
        [Parameter(Mandatory = $true)] [string]$Value
    )

    $currentUserValue = [Environment]::GetEnvironmentVariable($Name, "User")
    if ($currentUserValue -ne $Value) {
        [Environment]::SetEnvironmentVariable($Name, $Value, "User")
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
            VersionParts  = Get-VersionParts -Name $_.Name
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

function Restore-EnvironmentVariables {
    <#
    .SYNOPSIS
        Reads environment.json and applies environment variables to user and session.

    .DESCRIPTION
        Loads environment configuration from a JSON file and applies the variables
        to both the current user scope (persisted) and the current PowerShell session.

    .PARAMETER ConfigPath
        The full path to the environment.json configuration file.


    .EXAMPLE
        Restore-EnvironmentVariables -ConfigPath "C:\config\environment.json"

    .NOTES
        This function persists environment variables to the user profile registry.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ConfigPath

    )

    if (-not (Test-Path -Path $ConfigPath)) {
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
    $configData = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json

    Write-Host "Applying environment variables to current user and session..." -ForegroundColor Cyan
    $keys = $configData.PSObject.Properties.Name
    foreach ($key in $keys) {
        $value = [string]$configData.$key
        Set-EnvironmentVariableUserAndSession -Name $key -Value $value
    }
    Write-Host "Environment variables restored successfully." -ForegroundColor Green
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
    [CmdletBinding()]
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

    Write-Host "Writing environment summary to $ConfigPath..." -ForegroundColor Cyan
    $configData | ConvertTo-Json | Set-Content -Path $ConfigPath -Encoding utf8

    Write-Host "Applying environment variables to current user and session..." -ForegroundColor Cyan
    $entries = $configData.GetEnumerator()
    foreach ($kvp in $entries) {
        $key = $kvp.Key
        $value = [string]$kvp.Value
        Set-EnvironmentVariableUserAndSession -Name $key -Value $value
    }
    Write-Host "Environment variables persisted to user profile." -ForegroundColor Green

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

function Install-UEFiles {
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
        Install-UEFiles -UnpackPath "C:\UE\Unpack" -AddinsFolder "C:\addins"

    .EXAMPLE
        Install-UEFiles -UnpackPath "C:\UE\Unpack" -AddinsFolder "C:\addins" -SkipExisting
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

function Invoke-AddinCreation {
    <#
    .SYNOPSIS
        Creates a new UE add-in using the New-UEAddin script.

    .DESCRIPTION
        Validates that the New-UEAddin.ps1 script exists and invokes it
        with the specified add-in name.

    .PARAMETER AddinName
        The name of the add-in to create.

    .PARAMETER ScriptPath
        The path to the New-UEAddin.ps1 script.

    .EXAMPLE
        Invoke-AddinCreation -AddinName "MyAddin" -ScriptPath "C:\scripts\New-UEAddin.ps1"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$AddinName,

        [Parameter(Mandatory = $true)]
        [string]$ScriptPath
    )

    Write-Host "`nCreating add-in '$AddinName'..." -ForegroundColor Cyan

    if (-not (Test-Path -Path $ScriptPath)) {
        $exception = [System.IO.FileNotFoundException]::new("New-UEAddin.ps1 script not found at: $ScriptPath")
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
            $exception,
            'NewAddinScriptNotFound',
            [System.Management.Automation.ErrorCategory]::ObjectNotFound,
            $ScriptPath
        )
        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    Write-Verbose "Invoking New-UEAddin script with AddinName: $AddinName"
    & $ScriptPath -AddinName $AddinName
}

function Invoke-EnvironmentCleanup {
    <#
    .SYNOPSIS
        Invokes the Clear-UECustomizationEnvironment script.

    .DESCRIPTION
        Validates that the cleanup script exists and executes it.

    .PARAMETER ScriptsPath
        The path to the scripts directory containing Clear-UECustomizationEnvironment.ps1.

    .EXAMPLE
        Invoke-EnvironmentCleanup -ScriptsPath "C:\scripts"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ScriptsPath
    )

    $cleanupScriptPath = Join-Path -Path $ScriptsPath -ChildPath "Clear-UECustomizationEnvironment.ps1"

    if (-not (Test-Path -Path $cleanupScriptPath)) {
        $exception = [System.IO.FileNotFoundException]::new("Clear-UECustomizationEnvironment.ps1 script not found at: $cleanupScriptPath")
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
            $exception,
            'CleanupScriptNotFound',
            [System.Management.Automation.ErrorCategory]::ObjectNotFound,
            $cleanupScriptPath
        )
        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    Write-Verbose "Invoking cleanup script: $cleanupScriptPath"
    & $cleanupScriptPath
}

        function Clear-UECustomizationEnvironment {
            <#
            .SYNOPSIS
                Cleans up the UE customization environment folders.

            .DESCRIPTION
                Deletes the addins and pmllib folders. The source folder containing
                custom add-in projects is preserved; use Remove-UEAddin to delete
                individual add-ins.

            .OUTPUTS
                System.Void
            #>
            [CmdletBinding()]
            param ()

            $CustomizationRootDir = Get-Location
            Write-Host "Cleaning customization environment..." -ForegroundColor Cyan
            Write-Host "Using customization directory: $CustomizationRootDir" -ForegroundColor Gray

            $addinsFolder = Join-Path -Path $CustomizationRootDir -ChildPath "addins"
            $pmlLibFolder = Join-Path -Path $CustomizationRootDir -ChildPath "pmllib"
            $configPath = Join-Path -Path $CustomizationRootDir -ChildPath "environment.json"

            $foldersToCheck = @($addinsFolder, $pmlLibFolder)
            $existingFolders = @($foldersToCheck | Where-Object { Test-Path -Path $_ })
            $configExists = Test-Path -Path $configPath

            if ($existingFolders.Count -eq 0 -and -not $configExists) {
                Write-Host "No folders to clean. Environment is already clean." -ForegroundColor Green
                return
            }

            # Delete all existing folders and config
            $foldersToDelete = $existingFolders
            $deleteConfig = $configExists

            if ($foldersToDelete.Count -eq 0 -and -not $deleteConfig) {
                Write-Host "No folders selected for deletion. Cleanup cancelled." -ForegroundColor Yellow
                return
            }

            if ($foldersToDelete.Count -gt 0) {
                Write-Host "Deleting folders..." -ForegroundColor Yellow
                foreach ($folder in $foldersToDelete) {
                    try {
                        # Validate path is within expected customization directory (Security check)
                        $resolvedFolder = [System.IO.Path]::GetFullPath($folder)
                        $resolvedRoot = [System.IO.Path]::GetFullPath($CustomizationRootDir)
                        
                        if (-not $resolvedFolder.StartsWith($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
                            Write-Warning "Security: Skipping deletion of path outside customization directory: $folder"
                            continue
                        }

                        Remove-Item -Path $folder -Recurse -Force -ErrorAction Stop
                        Write-Host "  Deleted: $folder" -ForegroundColor Green
                    }
                    catch {
                        Write-Warning "Failed to delete: $folder. Error: $($_.Exception.Message)"
                    }
                }
            }

            if ($deleteConfig) {
                Write-Host "Removing environment configuration file..." -ForegroundColor Cyan
                Remove-Item -Path $configPath -Force -ErrorAction SilentlyContinue
                Write-Host "Environment configuration file removed." -ForegroundColor Green
            }

            Write-Host "Cleanup complete." -ForegroundColor Green
        }

        function Add-UEAddinStringEntry {
            [CmdletBinding()]
            param (
                [Parameter(Mandatory = $true)]
                [xml]$XmlDoc,

                [Parameter(Mandatory = $true)]
                [string]$Value
            )
            $strings = $XmlDoc.SelectNodes("//string")
            foreach ($s in $strings) {
                if ($s.InnerText -eq $Value) { return }
            }
            $newNode = $XmlDoc.CreateElement("string")
            $newNode.InnerText = $Value
            $XmlDoc.DocumentElement.AppendChild($newNode) | Out-Null
        }

        function Add-UECustomizationFileEntry {
            [CmdletBinding()]
            param (
                [Parameter(Mandatory = $true)]
                [xml]$XmlDoc,

                [Parameter(Mandatory = $true)]
                [string]$Name,

                [Parameter(Mandatory = $true)]
                [string]$Path
            )
            $nodes = $XmlDoc.SelectNodes("//UICustomizationFiles/CustomizationFile")
            foreach ($n in $nodes) {
                if ($n.GetAttribute("Name") -eq $Name -and $n.GetAttribute("Path") -eq $Path) { return }
            }
            $container = $XmlDoc.SelectSingleNode("//UICustomizationFiles")
            if (-not $container) {
                $container = $XmlDoc.CreateElement("UICustomizationFiles")
                $XmlDoc.DocumentElement.AppendChild($container) | Out-Null
            }
            $newNode = $XmlDoc.CreateElement("CustomizationFile")
            $newNode.SetAttribute("Name", $Name)
            $newNode.SetAttribute("Path", $Path)
            $container.AppendChild($newNode) | Out-Null
        }

        function Copy-UEAddinTemplate {
            [CmdletBinding()]
            param (
                [Parameter(Mandatory = $true)]
                [ValidateNotNullOrEmpty()]
                [ValidatePattern('^[a-zA-Z][a-zA-Z0-9_]*$', ErrorMessage = "AddinName must start with a letter and contain only alphanumeric characters and underscores.")]
                [string]$AddinName,
                
                [Parameter(Mandatory = $true)]
                [string]$Template,
                
                [Parameter(Mandatory = $true)]
                [string]$CustomizationRootDir,
                
                [Parameter(Mandatory = $false)]
                [string]$TemplatesDirOverride
            )

            # Additional path traversal validation (defense in depth)
            if ($AddinName -match '\.\.|[/\\:]') {
                $exception = [System.ArgumentException]::new(
                    "Invalid add-in name. Path traversal sequences detected. Only alphanumeric characters and underscores are allowed.",
                    "AddinName")
                $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                    $exception,
                    'InvalidAddinName',
                    [System.Management.Automation.ErrorCategory]::InvalidArgument,
                    $AddinName
                )
                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }

            # Validate base directories exist
            if (-not (Test-Path -Path $CustomizationRootDir -PathType Container)) {
                $exception = [System.IO.DirectoryNotFoundException]::new("Customization root directory not found: $CustomizationRootDir")
                $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                    $exception,
                    'CustomizationRootMissing',
                    [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                    $CustomizationRootDir
                )
                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }

            # Templates are in the plugin directory (navigate from helpers to create-addin skill)
            # or use override for testing
            if ([string]::IsNullOrWhiteSpace($TemplatesDirOverride)) {
                $pluginRoot = Split-Path -Path $PSScriptRoot -Parent
                $templatesDir = Join-Path -Path $pluginRoot -ChildPath "skills\create-addin\templates"
            }
            else {
                $templatesDir = $TemplatesDirOverride
            }
            $sourceTemplateDir = Join-Path -Path $templatesDir -ChildPath $Template

            if (-not (Test-Path -Path $templatesDir)) {
                $exception = [System.IO.DirectoryNotFoundException]::new("Templates folder not found at: $templatesDir")
                $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                    $exception,
                    'TemplatesFolderMissing',
                    [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                    $templatesDir
                )
                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }

            if (-not (Test-Path -Path $sourceTemplateDir)) {
                $exception = [System.IO.DirectoryNotFoundException]::new("Template folder not found at: $sourceTemplateDir")
                $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                    $exception,
                    'TemplateFolderMissing',
                    [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                    $sourceTemplateDir
                )
                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }

            # Construct and validate target path (Path Traversal Protection)
            $sourceDir = Join-Path -Path $CustomizationRootDir -ChildPath "source"
            $targetAddinDir = Join-Path -Path $sourceDir -ChildPath $AddinName

            # Ensure target directory is within source directory
            $resolvedTarget = [System.IO.Path]::GetFullPath($targetAddinDir)
            $resolvedSource = [System.IO.Path]::GetFullPath($sourceDir)

            if (-not $resolvedTarget.StartsWith($resolvedSource, [System.StringComparison]::OrdinalIgnoreCase)) {
                $exception = [System.Security.SecurityException]::new(
                    "Path traversal detected. Target directory must be within the source folder.")
                $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                    $exception,
                    'PathTraversalDetected',
                    [System.Management.Automation.ErrorCategory]::SecurityError,
                    $targetAddinDir
                )
                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }

            # Ensure source directory exists
            if (-not (Test-Path -Path $sourceDir)) {
                Write-Verbose "Creating source directory: $sourceDir"
                New-Item -Path $sourceDir -ItemType Directory -Force | Out-Null
            }

            # Check if directory already exists
            if (Test-Path -Path $targetAddinDir) {
                $exception = [System.IO.IOException]::new(
                    "Add-in directory already exists: $targetAddinDir. Use Remove-UEAddin to remove it first.")
                $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                    $exception,
                    'AddinAlreadyExists',
                    [System.Management.Automation.ErrorCategory]::ResourceExists,
                    $targetAddinDir
                )
                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }

            # Detect UIC presence before copying
            $templateUicFiles = Get-ChildItem -Path $sourceTemplateDir -Filter "*.uic" -File -ErrorAction SilentlyContinue
            $hasUicFile = $templateUicFiles.Count -gt 0

            Write-Host "Copying template and renaming to '$AddinName'..." -ForegroundColor Cyan
            
            # Target directory was already validated above for path traversal
            # $targetAddinDir is now safe to use

            $excludeDirs = @('bin', 'obj', '.vs', 'logs', 'log')
            $excludeFiles = @('*.user', '*.suo', '*.rsuser', '*.userprefs', '*.pdb', '*.ipdb', '*.iobj', '*.obj', '*.pch', '*.log', '*.tlog', '*.tmp', '*.cache', '*.ilk')
            $xdArgs = $excludeDirs | ForEach-Object { '/XD', $_ }
            $xfArgs = $excludeFiles | ForEach-Object { '/XF', $_ }
            $robocopyArgs = @($sourceTemplateDir, $targetAddinDir, '/E', '/NFL', '/NDL', '/NJH', '/NJS', '/NC', '/NS', '/R:2', '/W:1') + $xdArgs + $xfArgs
            & robocopy @robocopyArgs | Out-Null
            $rc = $LASTEXITCODE
            if ($rc -ge 8) {
                $exception = [System.InvalidOperationException]::new("Robocopy failed with exit code $rc while copying template.")
                $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                    $exception,
                    'RobocopyFailed',
                    [System.Management.Automation.ErrorCategory]::InvalidOperation,
                    $rc
                )
                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }

            $itemsToRename = Get-ChildItem -Path $targetAddinDir -Recurse -Force | Where-Object { $_.Name -like "*$Template*" }
            foreach ($item in $itemsToRename) {
                $newName = $item.Name -replace [regex]::Escape($Template), $AddinName
                Rename-Item -Path $item.FullName -NewName $newName -Force
            }

            $filesToEdit = Get-ChildItem -Path $targetAddinDir -Recurse -File -Force
            foreach ($file in $filesToEdit) {
                (Get-Content $file.FullName -Raw) -replace [regex]::Escape($Template), $AddinName | Set-Content $file.FullName -Encoding UTF8
            }

            return [pscustomobject]@{
                HasUicFile = $hasUicFile
            }
        }

        function Update-UEAddinUICEntries {
            [CmdletBinding()]
            param (
                [Parameter(Mandatory = $true)] [string]$AddinName,
                [Parameter(Mandatory = $true)] [string]$CustomizationRootDir,
                [Parameter(Mandatory = $true)] [bool]$HasUicFile,
                [Parameter(Mandatory = $false)] [string]$Module
            )

            if (-not $HasUicFile) {
                Write-Host "Template does not contain UI customization file, skipping module selection and addins/customization updates." -ForegroundColor Gray
                return
            }

            $addinsFolder = Join-Path -Path $CustomizationRootDir -ChildPath "addins"
            if (-not (Test-Path -Path $addinsFolder)) {
                $exception = [System.IO.DirectoryNotFoundException]::new("Addins folder not found at: $addinsFolder. Run setup first.")
                $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                    $exception,
                    'AddinsFolderMissing',
                    [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                    $addinsFolder
                )
                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }

            $moduleFileMap = @{
                'Model' = 'Design'
                'Engineering' = 'Tags'
                'EngineeringConfiguration' = 'Configuration'
                'Isodraft' = 'Isodraft'
                'Draw' = 'Draw'
                'Paragon' = 'Paragon'
                'Spooler' = 'Spooler'
                'Monitor' = 'Monitor'
            }

            $filePrefix = $moduleFileMap[$Module]
            Write-Host "Using module: $Module (files: $filePrefix)" -ForegroundColor Cyan

            $addInsXmlPath = Join-Path -Path $addinsFolder -ChildPath "${filePrefix}Addins.xml"
            if (-not (Test-Path -Path $addInsXmlPath)) {
                $exception = [System.IO.FileNotFoundException]::new("${filePrefix}Addins.xml not found at: $addInsXmlPath")
                $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                    $exception,
                    'AddinsXmlMissing',
                    [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                    $addInsXmlPath
                )
                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }
            [xml]$addInsXml = Get-Content -Path $addInsXmlPath
            Write-Host "Updating ${filePrefix}Addins.xml entries for '$AddinName'..." -ForegroundColor Cyan
            Add-UEAddinStringEntry -XmlDoc $addInsXml -Value $AddinName
            $addInsXml.Save($addInsXmlPath)

            $customizationXmlPath = Join-Path -Path $addinsFolder -ChildPath "${filePrefix}Customization.xml"
            if (-not (Test-Path -Path $customizationXmlPath)) {
                $exception = [System.IO.FileNotFoundException]::new("${filePrefix}Customization.xml not found at: $customizationXmlPath")
                $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                    $exception,
                    'CustomizationXmlMissing',
                    [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                    $customizationXmlPath
                )
                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }
            [xml]$customizationXml = Get-Content -Path $customizationXmlPath
            $uicPath = Join-Path -Path $addinsFolder -ChildPath "$AddinName.uic"
            Add-UECustomizationFileEntry -XmlDoc $customizationXml -Name $AddinName -Path $uicPath
            $customizationXml.Save($customizationXmlPath)
        }

        function New-UEAddin {
            <#
            .SYNOPSIS
                Creates a new UE add-in (XML entries, UIC file, and source copy).

            .PARAMETER AddinName
                The name of the add-in (letters only).

            .PARAMETER Template
                The name of the template to use. If not provided, the user will be 
                prompted to select from available templates.
            .PARAMETER Module
                The module to create the add-in for. Valid values are: Model, Engineering, EngineeringConfiguration,
                Isodraft, Draw, Paragon, Spooler, or Monitor. If not provided, the user will be prompted.
            #>
            [CmdletBinding()]
            param (
                [Parameter(Mandatory = $true)]
                [string]$AddinName,

                [Parameter(Mandatory = $false)]
                [string]$Template,
                [Parameter(Mandatory = $false)]
                [ValidateSet('Model', 'Engineering', 'EngineeringConfiguration', 'Isodraft', 'Draw', 'Paragon', 'Spooler', 'Monitor')]
                [string]$Module,


                [Parameter(Mandatory = $false)]
                [string]$CustomizationRootDirOverride,
                
                [Parameter(Mandatory = $false)]
                [string]$TemplatesDirOverride
            )

            if ($AddinName -notmatch '^[A-Za-z]+$') {
                $exception = [System.ArgumentException]::new("AddinName must only contain letters A-Z or a-z, with no spaces or special characters.")
                $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                    $exception,
                    'InvalidAddinName',
                    [System.Management.Automation.ErrorCategory]::InvalidArgument,
                    $AddinName
                )
                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }

            $CustomizationRootDir = if ([string]::IsNullOrWhiteSpace($CustomizationRootDirOverride)) { Get-Location } else { $CustomizationRootDirOverride }
            Write-Host "Using customization directory: $CustomizationRootDir" -ForegroundColor Gray

            Write-Host "Using template: $Template" -ForegroundColor Cyan

            $copyParams = @{
                AddinName            = $AddinName
                Template             = $Template
                CustomizationRootDir = $CustomizationRootDir
            }
            if (-not [string]::IsNullOrWhiteSpace($TemplatesDirOverride)) {
                $copyParams['TemplatesDirOverride'] = $TemplatesDirOverride
            }
            $copyResult = Copy-UEAddinTemplate @copyParams
            Update-UEAddinUICEntries -AddinName $AddinName -CustomizationRootDir $CustomizationRootDir -HasUicFile $copyResult.HasUicFile -Module $Module

            Write-Host "Add-in '$AddinName' created successfully." -ForegroundColor Green
        }

        function Remove-UEAddinStringEntry {
            [CmdletBinding()]
            param (
                [Parameter(Mandatory = $true)]
                [xml]$XmlDoc,

                [Parameter(Mandatory = $true)]
                [string]$Value
            )
            $strings = $XmlDoc.SelectNodes("//string")
            foreach ($s in $strings) {
                if ($s.InnerText -eq $Value) {
                    $s.ParentNode.RemoveChild($s) | Out-Null
                    return $true
                }
            }
            return $false
        }

        function Remove-UECustomizationFileEntry {
            [CmdletBinding()]
            param (
                [Parameter(Mandatory = $true)]
                [xml]$XmlDoc,

                [Parameter(Mandatory = $true)]
                [string]$Name
            )
            $nodes = $XmlDoc.SelectNodes("//UICustomizationFiles/CustomizationFile")
            foreach ($n in $nodes) {
                if ($n.GetAttribute("Name") -eq $Name) {
                    $n.ParentNode.RemoveChild($n) | Out-Null
                    return $true
                }
            }
            return $false
        }

        function Remove-UEAddin {
            <#
            .SYNOPSIS
                Removes UE add-in entries and files.

            .PARAMETER AddinName
                The add-in name to remove.
            #>
            [CmdletBinding()]
            param (
                [Parameter(Mandatory = $true)]
                [string]$AddinName
            )

            if ($AddinName -notmatch '^[A-Za-z]+$') {
                $exception = [System.ArgumentException]::new("AddinName must only contain letters A-Z or a-z, with no spaces or special characters.")
                $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                    $exception,
                    'InvalidAddinName',
                    [System.Management.Automation.ErrorCategory]::InvalidArgument,
                    $AddinName
                )
                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }

            $CustomizationRootDir = Get-Location
            Write-Host "Removing add-in '$AddinName'..." -ForegroundColor Cyan
            Write-Host "Using customization directory: $CustomizationRootDir" -ForegroundColor Gray

            $addinsFolder = Join-Path -Path $CustomizationRootDir -ChildPath "addins"
            if (-not (Test-Path -Path $addinsFolder)) {
                Write-Warning "Addins folder not found at: $addinsFolder"
            }

            if (Test-Path -Path $addinsFolder) {
                # Remove from all *Addins.xml files
                $addinsXmlFiles = Get-ChildItem -Path $addinsFolder -Filter "*Addins.xml" -File -ErrorAction SilentlyContinue
                if (-not $addinsXmlFiles -or $addinsXmlFiles.Count -eq 0) {
                    Write-Warning "No *Addins.xml files found in: $addinsFolder"
                } else {
                    foreach ($file in $addinsXmlFiles) {
                        try {
                            [xml]$xml = Get-Content -Path $file.FullName
                            Write-Host "Removing entry from $($file.Name)..." -ForegroundColor Cyan
                            $removed = Remove-UEAddinStringEntry -XmlDoc $xml -Value $AddinName
                            if ($removed) { $xml.Save($file.FullName); Write-Host "  Removed from $($file.Name)" -ForegroundColor Green }
                            else { Write-Host "  Entry not found in $($file.Name)" -ForegroundColor Yellow }
                        }
                        catch {
                            Write-Warning "Failed processing $($file.Name): $($_.Exception.Message)"
                        }
                    }
                }

                # Remove from all *Customization.xml files
                $customizationXmlFiles = Get-ChildItem -Path $addinsFolder -Filter "*Customization.xml" -File -ErrorAction SilentlyContinue
                if (-not $customizationXmlFiles -or $customizationXmlFiles.Count -eq 0) {
                    Write-Warning "No *Customization.xml files found in: $addinsFolder"
                } else {
                    foreach ($file in $customizationXmlFiles) {
                        try {
                            [xml]$xml = Get-Content -Path $file.FullName
                            Write-Host "Removing entry from $($file.Name)..." -ForegroundColor Cyan
                            $removed = Remove-UECustomizationFileEntry -XmlDoc $xml -Name $AddinName
                            if ($removed) { $xml.Save($file.FullName); Write-Host "  Removed from $($file.Name)" -ForegroundColor Green }
                            else { Write-Host "  Entry not found in $($file.Name)" -ForegroundColor Yellow }
                        }
                        catch {
                            Write-Warning "Failed processing $($file.Name): $($_.Exception.Message)"
                        }
                    }
                }

                # Remove UIC file
                $uicPath = Join-Path -Path $addinsFolder -ChildPath "$AddinName.uic"
                if (Test-Path -Path $uicPath) {
                    Write-Host "Deleting UIC file..." -ForegroundColor Cyan
                    try { Remove-Item -Path $uicPath -Force; Write-Host "  Deleted: $uicPath" -ForegroundColor Green }
                    catch { Write-Warning "Failed to delete UIC file: $uicPath. Error: $($_.Exception.Message)" }
                } else { Write-Host "  UIC file not found: $uicPath" -ForegroundColor Yellow }

                # Remove DLL from addins folder
                $dllPath = Join-Path -Path $addinsFolder -ChildPath "$AddinName.dll"
                if (Test-Path -Path $dllPath) {
                    Write-Host "Deleting DLL file..." -ForegroundColor Cyan
                    try { Remove-Item -Path $dllPath -Force; Write-Host "  Deleted: $dllPath" -ForegroundColor Green }
                    catch { Write-Warning "Failed to delete DLL file: $dllPath. Error: $($_.Exception.Message)" }
                } else { Write-Host "  DLL file not found: $dllPath" -ForegroundColor Yellow }
            }

            $addinSourceDir = Join-Path -Path $CustomizationRootDir -ChildPath "source/$AddinName"
            if (Test-Path -Path $addinSourceDir) {
                Write-Host "Deleting add-in source folder: $addinSourceDir" -ForegroundColor Cyan
                try { Remove-Item -Path $addinSourceDir -Recurse -Force; Write-Host "  Deleted: $addinSourceDir" -ForegroundColor Green }
                catch { Write-Warning "Failed to delete add-in source folder: $addinSourceDir. Error: $($_.Exception.Message)" }
            } else { Write-Host "  Add-in source folder not found: $addinSourceDir" -ForegroundColor Yellow }

            Write-Host "Add-in '$AddinName' removed successfully." -ForegroundColor Green
        }

        Export-ModuleMember -Function Get-VersionParts, Find-RequiredFile, Invoke-UEUnpack, Restore-EnvironmentVariables, Set-EnvironmentVariableUserAndSession, Set-EnvironmentConfiguration, Initialize-DirectoryStructure, Install-UEFiles, Invoke-AddinCreation, Invoke-EnvironmentCleanup, Clear-UECustomizationEnvironment, New-UEAddin, Remove-UEAddin, Update-SampleCsprojReferences
