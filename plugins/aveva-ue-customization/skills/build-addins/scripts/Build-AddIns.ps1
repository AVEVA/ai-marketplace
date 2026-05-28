param(
    [Parameter(Mandatory = $false)]
    [string]$Directory = "source",
    [string]$Configuration = "Debug"
)

$ErrorActionPreference = "Stop"

# Use current workspace directory to find environment and source files
$workspaceRoot = Get-Location
# Reference helper module from plugin helpers folder (3 levels up to plugin root)
$modulePath = Join-Path -Path $PSScriptRoot -ChildPath "..\..\..\helpers\UECustomizationFunctions.psm1"
Import-Module -Name $modulePath -Force -ErrorAction Stop

$configPath = Join-Path -Path $workspaceRoot -ChildPath "environment.json"

# Load environment variables from configuration if it exists
if (Test-Path $configPath) {
    Restore-EnvironmentVariables -ConfigPath $configPath
}

$targetDir = if ([System.IO.Path]::IsPathRooted($Directory)) { $Directory } else { Join-Path $workspaceRoot $Directory }

if (-not (Test-Path -Path $targetDir)) {
    Write-Error "Target directory not found: $targetDir"
    exit 1
}

$projects = Get-ChildItem -Path $targetDir -Filter "*.csproj" -Recurse -File | Sort-Object FullName
if (-not $projects) {
    Write-Warning "No csproj files found under $targetDir"
    exit 0
}

$failed = @()
foreach ($proj in $projects) {
    Write-Host "--- Building $($proj.FullName) ---" -ForegroundColor Cyan
    dotnet build $proj.FullName -c $Configuration -clp:Summary -nologo
    if ($LASTEXITCODE -ne 0) {
        $failed += $proj.FullName
    }
}

if ($failed.Count -gt 0) {
    Write-Host "Build failures:" -ForegroundColor Red
    $failed | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
    exit 1
}

Write-Host "Build succeeded for all projects under $targetDir" -ForegroundColor Green
exit 0