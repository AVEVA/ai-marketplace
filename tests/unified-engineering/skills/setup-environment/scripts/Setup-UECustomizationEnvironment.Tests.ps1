#Requires -Modules Pester

BeforeAll {
    $repoRoot = Join-Path $PSScriptRoot '..' '..' '..' '..' '..'
    $sourceScriptPath = Join-Path $repoRoot 'plugins' 'unified-engineering' 'skills' 'setup-environment' 'scripts' 'Setup-UECustomizationEnvironment.ps1'
    $cleanupSourcePath = Join-Path $repoRoot 'plugins' 'unified-engineering' 'skills' 'clear-environment' 'scripts' 'Clear-UECustomizationEnvironment.ps1'
}

Describe 'Setup-UECustomizationEnvironment skill script' -Tag 'Unit' {
    BeforeEach {
        $workspace = Join-Path $TestDrive ([guid]::NewGuid().ToString())
        New-Item $workspace -ItemType Directory | Out-Null
        $previousMarker = $env:UE_RESTORE_TEST
        $skillRoot = Join-Path $workspace 'plugin' 'skills'
        $scriptPath = Join-Path $skillRoot 'setup-environment' 'scripts' 'Setup-UECustomizationEnvironment.ps1'
        $restoreScriptPath = Join-Path $skillRoot 'restore-environment' 'scripts' 'Restore-UEEnvironment.ps1'
        $cleanupScriptPath = Join-Path $skillRoot 'clear-environment' 'scripts' 'Clear-UECustomizationEnvironment.ps1'
        New-Item (Split-Path $scriptPath), (Split-Path $restoreScriptPath), (Split-Path $cleanupScriptPath) -ItemType Directory -Force | Out-Null
        Copy-Item $sourceScriptPath $scriptPath
        Copy-Item $cleanupSourcePath $cleanupScriptPath
        'param([string]$ConfigPath); $env:UE_RESTORE_TEST = $ConfigPath' | Set-Content $restoreScriptPath
        . $scriptPath
    }

    AfterEach {
        $env:UE_RESTORE_TEST = $previousMarker
    }

    It 'parses version <Version>' -ForEach @(
        @{ Version = '1.2.3'; Expected = @(1, 2, 3) }
        @{ Version = 'v10.2.03-beta'; Expected = @(10, 2, 3) }
        @{ Version = '5'; Expected = @(5) }
    ) {
        @(Get-VersionArray -Name $Version) | Should -Be $Expected
    }

    It 'returns no parts for a nonnumeric version' {
        Get-VersionArray -Name 'no-numbers-here' | Should -BeNullOrEmpty
    }

    It 'creates the environment directories including nested paths' {
        $addins = Join-Path $workspace 'nested' 'addins'
        $pmllib = Join-Path $workspace 'nested' 'pmllib'
        $source = Join-Path $workspace 'nested' 'source'

        Initialize-DirectoryStructure -AddinsFolder $addins -PmlLibFolder $pmllib -SourceFolder $source

        foreach ($path in @($addins, $source, $pmllib, (Join-Path $pmllib 'forms'), (Join-Path $pmllib 'functions'), (Join-Path $pmllib 'objects'))) {
            Test-Path $path -PathType Container | Should -BeTrue
        }
    }

    It 'writes all four environment settings and delegates application' {
        $configPath = Join-Path $workspace 'environment.json'
        $addins = Join-Path $workspace 'addins'
        $pmllib = Join-Path $workspace 'pmllib'
        $unpack = Join-Path $workspace 'unpacked'

        $config = Set-EnvironmentConfiguration -ConfigPath $configPath -AddinsFolder $addins -PmlLibFolder $pmllib -UnpackPath $unpack

        $saved = Get-Content $configPath -Raw | ConvertFrom-Json
        $saved.CAF_ADDINS_PATH | Should -Be $addins
        $saved.CAF_UIC_PATH | Should -Be $addins
        $saved.CUSTOM_PMLLIB | Should -Be $pmllib
        $saved.UNIFIED_ENGINEERING_REFERENCE_PATH | Should -Be $unpack
        $config.Count | Should -Be 4
        $env:UE_RESTORE_TEST | Should -Be $configPath
    }

    It 'reports a missing UE command without unpacking' {
        Mock Get-Command { throw 'UE unavailable' } -ParameterFilter { $Name -eq 'UE' }

        { Invoke-UEUnpack } | Should -Throw '*UE not found*'
    }

    It 'copies unpacked configuration files' {
        $unpack = Join-Path $workspace 'unpack'
        $addins = Join-Path $workspace 'addins'
        New-Item $unpack, $addins -ItemType Directory | Out-Null
        '<ArrayOfString />' | Set-Content (Join-Path $unpack 'DesignAddins.xml')
        '<Design />' | Set-Content (Join-Path $unpack 'DesignCustomization.xml')

        Install-UEConfiguration -UnpackPath $unpack -AddinsFolder $addins

        Test-Path (Join-Path $addins 'DesignAddins.xml') | Should -BeTrue
        Test-Path (Join-Path $addins 'DesignCustomization.xml') | Should -BeTrue
    }

    It 'preserves existing configuration when reusing an environment' {
        $unpack = Join-Path $workspace 'unpack'
        $addins = Join-Path $workspace 'addins'
        New-Item $unpack, $addins -ItemType Directory | Out-Null
        'original' | Set-Content (Join-Path $unpack 'DesignAddins.xml')
        'customized' | Set-Content (Join-Path $addins 'DesignAddins.xml')

        Install-UEConfiguration -UnpackPath $unpack -AddinsFolder $addins -SkipExisting

        Get-Content (Join-Path $addins 'DesignAddins.xml') | Should -Be 'customized'
    }

    It 'accepts an unpack directory without configuration files' {
        { Install-UEConfiguration -UnpackPath $workspace -AddinsFolder (Join-Path $workspace 'addins') } | Should -Not -Throw
    }

    It 'uses the cleanup skill before rebuilding an environment and preserves source' {
        $unpack = Join-Path $workspace 'unpacked'
        New-Item $unpack, (Join-Path $workspace 'addins'), (Join-Path $workspace 'source') -ItemType Directory -Force | Out-Null
        'old' | Set-Content (Join-Path $workspace 'addins' 'Old.dll')
        'keep' | Set-Content (Join-Path $workspace 'source' 'Keep.cs')
        Mock Invoke-UEUnpack { $unpack }
        Push-Location $workspace
        try {
            Initialize-UECustomizationEnvironment
        }
        finally {
            Pop-Location
        }

        Test-Path (Join-Path $workspace 'addins' 'Old.dll') | Should -BeFalse
        Test-Path (Join-Path $workspace 'addins') -PathType Container | Should -BeTrue
        Get-Content (Join-Path $workspace 'source' 'Keep.cs') | Should -Be 'keep'
        Test-Path (Join-Path $workspace 'environment.json') | Should -BeTrue
        Should -Invoke Invoke-UEUnpack -Times 1 -Exactly -ParameterFilter { -not $ReuseExisting }
    }

    It 'skips cleanup and reuses unpacked content when requested' {
        $unpack = Join-Path $workspace 'unpacked'
        New-Item $unpack, (Join-Path $workspace 'addins') -ItemType Directory -Force | Out-Null
        'keep' | Set-Content (Join-Path $workspace 'addins' 'Existing.dll')
        Mock Invoke-UEUnpack { $unpack }
        Push-Location $workspace
        try {
            Initialize-UECustomizationEnvironment -ReuseEnvironment
        }
        finally {
            Pop-Location
        }

        Get-Content (Join-Path $workspace 'addins' 'Existing.dll') | Should -Be 'keep'
        Should -Invoke Invoke-UEUnpack -Times 1 -Exactly -ParameterFilter { $ReuseExisting }
    }
}