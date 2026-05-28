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

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$AddinName,

    [Parameter(Mandatory = $true)]
    [string]$Template,

    [Parameter(Mandatory = $true)]
    [ValidateSet('Model', 'Engineering', 'EngineeringConfiguration', 'Isodraft', 'Draw', 'Paragon', 'Spooler', 'Monitor')]
    [string]$Module
)

begin {
    $ErrorActionPreference = "Stop"
    # Reference helper module from plugin helpers folder (3 levels up to plugin root)
    $modulePath = Join-Path -Path $PSScriptRoot -ChildPath "..\..\..\helpers\UECustomizationFunctions.psm1"
    Import-Module -Name $modulePath -Force -ErrorAction Stop
}

process {
    $invokeParams = @{ AddinName = $AddinName }
    if ($PSBoundParameters.ContainsKey('Template')) { $invokeParams.Template = $Template }
    if ($PSBoundParameters.ContainsKey('Module'))   { $invokeParams.Module   = $Module }
    New-UEAddin @invokeParams
}

