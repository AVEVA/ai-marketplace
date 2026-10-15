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

if ($MyInvocation.InvocationName -ne '.') {
    $ErrorActionPreference = "Stop"
    Remove-UEAddin -AddinName $AddinName
}
