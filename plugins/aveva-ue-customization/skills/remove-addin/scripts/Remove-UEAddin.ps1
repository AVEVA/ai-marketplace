<#
.SYNOPSIS
    Removes an AVEVA Unified Engineering add-in configuration.

.DESCRIPTION
    This script removes an add-in configuration by:
    - Removing the entry from DesignAddins.xml
    - Removing the CustomizationFile entry from DesignCustomization.xml
    - Deleting the UIC (User Interface Customization) file for the add-in

.PARAMETER AddinName
    The name of the add-in to remove.
    Example: "MyCustomAddin"

.EXAMPLE
    .\Remove-UEAddin.ps1 -AddinName "MyCustomAddin"

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$AddinName
)

begin {
    $ErrorActionPreference = "Stop"
    # Reference helper module from plugin helpers folder (3 levels up to plugin root)
    $modulePath = Join-Path -Path $PSScriptRoot -ChildPath "..\..\..\helpers\UECustomizationFunctions.psm1"
    Import-Module -Name $modulePath -Force -ErrorAction Stop
}

process {
    Remove-UEAddin -AddinName $AddinName
}

end {
}

