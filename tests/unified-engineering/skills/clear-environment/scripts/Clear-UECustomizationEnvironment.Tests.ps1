#Requires -Modules Pester

BeforeAll {
    $repoRoot = Join-Path $PSScriptRoot '..' '..' '..' '..' '..'
    $scriptPath = Join-Path $repoRoot 'plugins' 'unified-engineering' 'skills' 'clear-environment' 'scripts' 'Clear-UECustomizationEnvironment.ps1'
    . $scriptPath
}

Describe 'Clear-UECustomizationEnvironment skill script' -Tag 'Unit' {
    BeforeEach {
        $workspace = Join-Path $TestDrive ([guid]::NewGuid().ToString())
        New-Item $workspace -ItemType Directory | Out-Null
        Push-Location $workspace
    }

    AfterEach {
        Pop-Location
    }

    It 'removes generated folders and configuration but preserves add-in source' {
        New-Item (Join-Path $workspace 'addins'), (Join-Path $workspace 'pmllib'), (Join-Path $workspace 'source') -ItemType Directory | Out-Null
        '{}' | Set-Content (Join-Path $workspace 'environment.json')
        'keep' | Set-Content (Join-Path $workspace 'source' 'Keep.cs')

        & $scriptPath

        Test-Path (Join-Path $workspace 'addins') | Should -BeFalse
        Test-Path (Join-Path $workspace 'pmllib') | Should -BeFalse
        Test-Path (Join-Path $workspace 'environment.json') | Should -BeFalse
        Get-Content (Join-Path $workspace 'source' 'Keep.cs') | Should -Be 'keep'
    }

    It 'removes configuration even when generated folders do not exist' {
        '{}' | Set-Content (Join-Path $workspace 'environment.json')

        & $scriptPath

        Test-Path (Join-Path $workspace 'environment.json') | Should -BeFalse
    }

    It 'can run again on an already clean workspace' {
        { & $scriptPath; & $scriptPath } | Should -Not -Throw
    }
}