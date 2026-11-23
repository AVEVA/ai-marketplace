<#
.SYNOPSIS
    Creates a new AVEVA Unified Engineering add-in.

.DESCRIPTION
    Creates a new add-in configuration and sets up the add-in source folder by copying
    the specified template. If no template is specified, the user is prompted to choose
    from available templates in the templates folder.

.PARAMETER AddinName
    The name of the add-in to create (letters only, no spaces or special characters).

.PARAMETER Template
    The name of the template to use (e.g., "TemplateAddIn"). If not provided, the user
    will be prompted to select from available templates.
.PARAMETER Module
    The module to create the add-in for. Valid values are: Model, Engineering, EngineeringConfiguration,
    Isodraft, Draw, Paragon, Spooler, or Monitor. If not provided, the user will be prompted.


.EXAMPLE
    .\New-UEAddin.ps1 -AddinName "MyAddin"

.EXAMPLE
    .\New-UEAddin.ps1 -AddinName "MyAddin" -Template "TemplateAddIn"
.EXAMPLE
    .\New-UEAddin.ps1 -AddinName "MyAddin" -Template "TemplateAddIn" -Module "Engineering"


#>

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory = $true)]
    [string]$AddinName,

    [Parameter(Mandatory = $true)]
    [string]$Template,

    [Parameter(Mandatory = $true)]
    [ValidateSet('Model', 'Engineering', 'EngineeringConfiguration', 'Isodraft', 'Draw', 'Paragon', 'Spooler', 'Monitor')]
    [string]$Module
)

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

    if ([string]::IsNullOrWhiteSpace($TemplatesDirOverride)) {
        $templatesDir = Join-Path $PSScriptRoot '..' 'templates'
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

function Update-UEAddInUIC {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Internal helper; New-UEAddin gates the operation with ShouldProcess.')]
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
    [CmdletBinding(SupportsShouldProcess)]
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

    if (-not $PSCmdlet.ShouldProcess($AddinName, 'Create add-in')) { return }

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
    Update-UEAddInUIC -AddinName $AddinName -CustomizationRootDir $CustomizationRootDir -HasUicFile $copyResult.HasUicFile -Module $Module

    Write-Host "Add-in '$AddinName' created successfully." -ForegroundColor Green
}

if ($MyInvocation.InvocationName -ne '.') {
    $ErrorActionPreference = "Stop"
    $invokeParams = @{ AddinName = $AddinName }
    if ($PSBoundParameters.ContainsKey('Template')) { $invokeParams.Template = $Template }
    if ($PSBoundParameters.ContainsKey('Module'))   { $invokeParams.Module   = $Module }
    New-UEAddin @invokeParams
}
