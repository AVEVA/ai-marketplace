#Requires -Modules Pester

BeforeAll {
    $repoRoot = Join-Path $PSScriptRoot '..' '..' '..' '..' '..'
    $scriptPath = Join-Path $repoRoot 'plugins' 'unified-engineering' 'skills' 'remove-addin' 'scripts' 'Remove-UEAddin.ps1'
    . $scriptPath -AddinName 'Invalid-Name'
}

Describe 'Remove-UEAddin skill script' -Tag 'Unit' {
    BeforeEach {
        $workspace = Join-Path $TestDrive ([guid]::NewGuid().ToString())
        New-Item $workspace -ItemType Directory | Out-Null
        Push-Location $workspace
    }

    AfterEach {
        Pop-Location
    }

    It 'removes only the requested add-in registrations and files' {
        $addins = Join-Path $workspace 'addins'
        New-Item $addins, (Join-Path $workspace 'source' 'Target'), (Join-Path $workspace 'source' 'Keep') -ItemType Directory -Force | Out-Null
        '<ArrayOfString><string>Target</string><string>Keep</string></ArrayOfString>' | Set-Content (Join-Path $addins 'DesignAddins.xml')
        '<Design><UICustomizationFiles><CustomizationFile Name="Target" Path="Target.uic" /><CustomizationFile Name="Keep" Path="Keep.uic" /></UICustomizationFiles></Design>' | Set-Content (Join-Path $addins 'DesignCustomization.xml')
        foreach ($file in @('Target.uic', 'Target.dll', 'Keep.uic', 'Keep.dll')) {
            'fixture' | Set-Content (Join-Path $addins $file)
        }

        & $scriptPath -AddinName Target

        Get-Content (Join-Path $addins 'DesignAddins.xml') -Raw | Should -Not -Match 'Target'
        Get-Content (Join-Path $addins 'DesignCustomization.xml') -Raw | Should -Not -Match 'Target'
        Get-Content (Join-Path $addins 'DesignAddins.xml') -Raw | Should -Match 'Keep'
        Get-Content (Join-Path $addins 'DesignCustomization.xml') -Raw | Should -Match 'Keep'
        foreach ($path in @((Join-Path $addins 'Target.uic'), (Join-Path $addins 'Target.dll'), (Join-Path $workspace 'source' 'Target'))) {
            Test-Path $path | Should -BeFalse
        }
        foreach ($path in @((Join-Path $addins 'Keep.uic'), (Join-Path $addins 'Keep.dll'), (Join-Path $workspace 'source' 'Keep'))) {
            Test-Path $path | Should -BeTrue
        }
    }

    It 'rejects invalid add-in names before deleting files' {
        { Remove-UEAddin -AddinName '../Target' } | Should -Throw '*AddinName must only contain letters*'
    }
}