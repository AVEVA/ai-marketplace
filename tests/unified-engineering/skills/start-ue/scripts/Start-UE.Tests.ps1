#Requires -Modules Pester

BeforeAll {
    $repoRoot = Join-Path $PSScriptRoot '..' '..' '..' '..' '..'
    $sourceScriptPath = Join-Path $repoRoot 'plugins' 'unified-engineering' 'skills' 'start-ue' 'scripts' 'Start-UE.ps1'

    function UE {}
}

Describe 'Start-UE skill script' -Tag 'Unit' {
    BeforeEach {
        $workspace = Join-Path $TestDrive ([guid]::NewGuid().ToString())
        New-Item $workspace -ItemType Directory | Out-Null
        Push-Location $workspace
        $previousMarker = $env:UE_RESTORE_TEST
        $skillRoot = Join-Path $TestDrive 'skills'
        $scriptPath = Join-Path $skillRoot 'start-ue' 'scripts' 'Start-UE.ps1'
        $restoreScriptPath = Join-Path $skillRoot 'restore-environment' 'scripts' 'Restore-UEEnvironment.ps1'
        New-Item (Split-Path $scriptPath), (Split-Path $restoreScriptPath) -ItemType Directory -Force | Out-Null
        Copy-Item $sourceScriptPath $scriptPath
        'param([string]$ConfigPath); $env:UE_RESTORE_TEST = $ConfigPath' | Set-Content $restoreScriptPath
        Mock UE { $global:LASTEXITCODE = 0 }
    }

    AfterEach {
        $env:UE_RESTORE_TEST = $previousMarker
        Pop-Location
    }

    It 'delegates restoration in the current process before launching UE' {
        $configPath = Join-Path $workspace 'environment.json'
        '{}' | Set-Content $configPath
        Mock UE {
            $env:UE_RESTORE_TEST | Should -Be $configPath
            $global:LASTEXITCODE = 0
        }

        & $scriptPath -Module Engineering

        $env:UE_RESTORE_TEST | Should -Be $configPath
        Should -Invoke UE -Times 1 -Exactly
    }

    It 'does not launch UE when restoration fails' {
        '{}' | Set-Content (Join-Path $workspace 'environment.json')
        'throw "Restore failed"' | Set-Content $restoreScriptPath

        { & $scriptPath } | Should -Throw '*Restore failed*'

        Should -Invoke UE -Times 0 -Exactly
    }

    It 'launches UE without requiring the removed helper module' {
        & $scriptPath -Module Engineering -Project TestProject -Mdb ALL

        $LASTEXITCODE | Should -Be 0
        Should -Invoke UE -Times 1 -Exactly
    }

    It 'preserves the UE failure exit code' {
        Mock UE { $global:LASTEXITCODE = 7 }

        & $scriptPath

        $LASTEXITCODE | Should -Be 7
    }
}