#Requires -Modules Pester

BeforeAll {
    $repoRoot = Join-Path $PSScriptRoot '..' '..' '..' '..' '..'
    $sourceScriptPath = Join-Path $repoRoot 'plugins' 'unified-engineering' 'skills' 'build-addins' 'scripts' 'Build-AddIns.ps1'

    function dotnet {}
}

Describe 'Build-AddIns skill script' -Tag 'Unit' {
    BeforeEach {
        $workspace = Join-Path $TestDrive ([guid]::NewGuid().ToString())
        New-Item $workspace -ItemType Directory | Out-Null
        Push-Location $workspace
        $previousMarker = $env:UE_RESTORE_TEST
        $skillRoot = Join-Path $TestDrive 'skills'
        $scriptPath = Join-Path $skillRoot 'build-addins' 'scripts' 'Build-AddIns.ps1'
        $restoreScriptPath = Join-Path $skillRoot 'restore-environment' 'scripts' 'Restore-UEEnvironment.ps1'
        New-Item (Split-Path $scriptPath), (Split-Path $restoreScriptPath) -ItemType Directory -Force | Out-Null
        Copy-Item $sourceScriptPath $scriptPath
        'param([string]$ConfigPath); $env:UE_RESTORE_TEST = $ConfigPath' | Set-Content $restoreScriptPath
        Mock dotnet { $global:LASTEXITCODE = 0 }
    }

    AfterEach {
        $env:UE_RESTORE_TEST = $previousMarker
        Pop-Location
    }

    It 'delegates restoration in the current process before building' {
        $configPath = Join-Path $workspace 'environment.json'
        '{}' | Set-Content $configPath
        $source = Join-Path $workspace 'source'
        New-Item $source -ItemType Directory | Out-Null
        '<Project />' | Set-Content (Join-Path $source 'Addin.csproj')
        Mock dotnet {
            $env:UE_RESTORE_TEST | Should -Be $configPath
            $global:LASTEXITCODE = 0
        }

        & $scriptPath

        $env:UE_RESTORE_TEST | Should -Be $configPath
        Should -Invoke dotnet -Times 1 -Exactly
    }

    It 'builds projects without requiring the removed helper module' {
        $source = Join-Path $workspace 'source'
        New-Item $source -ItemType Directory | Out-Null
        '<Project />' | Set-Content (Join-Path $source 'Addin.csproj')

        & $scriptPath -Configuration Release

        $LASTEXITCODE | Should -Be 0
        Should -Invoke dotnet -Times 1 -Exactly
    }

    It 'does not build when restoration fails' {
        '{}' | Set-Content (Join-Path $workspace 'environment.json')
        'throw "Restore failed"' | Set-Content $restoreScriptPath

        { & $scriptPath } | Should -Throw '*Restore failed*'

        Should -Invoke dotnet -Times 0 -Exactly
    }

    It 'returns failure when a project build fails' {
        $source = Join-Path $workspace 'source'
        New-Item $source -ItemType Directory | Out-Null
        '<Project />' | Set-Content (Join-Path $source 'Addin.csproj')
        Mock dotnet { $global:LASTEXITCODE = 1 }

        & $scriptPath

        $LASTEXITCODE | Should -Be 1
    }
}