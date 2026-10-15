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

if ($MyInvocation.InvocationName -ne '.') {
    $ErrorActionPreference = "Stop"
    Clear-UECustomizationEnvironment
}
