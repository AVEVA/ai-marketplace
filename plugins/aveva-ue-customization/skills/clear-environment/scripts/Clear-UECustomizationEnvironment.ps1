<#
.SYNOPSIS
    Cleans up the UE Customization environment by removing generated folders.

.DESCRIPTION
    This script removes the samples and addins folders from the
    customization directory. Prompts for confirmation when deleting folders
    with more than 100 items.

.EXAMPLE
    .\Clear-UECustomizationEnvironment.ps1

#>

[CmdletBinding()]
param ()

begin {
    $ErrorActionPreference = "Stop"
    # Reference helper module from plugin helpers folder (3 levels up to plugin root)
    $modulePath = Join-Path -Path $PSScriptRoot -ChildPath "..\..\..\helpers\UECustomizationFunctions.psm1"
    Import-Module -Name $modulePath -Force -ErrorAction Stop
}

process {
    Clear-UECustomizationEnvironment
}

end {
}
