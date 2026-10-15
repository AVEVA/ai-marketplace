#Requires -Modules Pester

BeforeAll {
    $repoRoot = Join-Path $PSScriptRoot '..' '..' '..' '..' '..'
    $scriptPath = Join-Path $repoRoot 'plugins' 'unified-engineering' 'skills' 'create-addin' 'scripts' 'New-UEAddin.ps1'
    . $scriptPath -AddinName 'Invalid-Name' -Template 'NotUsed' -Module 'Model'

    function robocopy {
        param([string]$SourceDirectory, [string]$DestinationDirectory)
    }
}

Describe 'New-UEAddin skill script' -Tag 'Unit' {
    BeforeEach {
        $workspace = Join-Path $TestDrive ([guid]::NewGuid().ToString())
        $templates = Join-Path $workspace 'templates'
        $addins = Join-Path $workspace 'addins'
        New-Item $templates, $addins -ItemType Directory -Force | Out-Null
        '<ArrayOfString />' | Set-Content (Join-Path $addins 'DesignAddins.xml')
        '<Design />' | Set-Content (Join-Path $addins 'DesignCustomization.xml')

        Mock robocopy {
            param($SourceDirectory, $DestinationDirectory)
            New-Item $DestinationDirectory -ItemType Directory -Force | Out-Null
            Get-ChildItem $SourceDirectory -File | Where-Object Extension -in '.cs', '.uic' |
                Copy-Item -Destination $DestinationDirectory
            $global:LASTEXITCODE = 0
        }
    }

    It 'loads its own functions without running add-in creation' {
        Get-Command New-UEAddin -CommandType Function | Should -Not -BeNullOrEmpty
        Get-Command Copy-UEAddinTemplate -CommandType Function | Should -Not -BeNullOrEmpty
    }

    It 'rejects invalid add-in name <AddinName>' -ForEach @(
        @{ AddinName = 'Test-Addin' }
        @{ AddinName = 'TestAddin123' }
        @{ AddinName = 'Test Addin' }
    ) {
        { New-UEAddin -AddinName $AddinName } | Should -Throw '*AddinName must only contain letters*'
    }

    It 'creates source and registers UI entries for a template with a UIC file' {
        $template = Join-Path $templates 'WithUi'
        New-Item $template -ItemType Directory | Out-Null
        'class WithUi {}' | Set-Content (Join-Path $template 'WithUi.cs')
        '<UIC />' | Set-Content (Join-Path $template 'WithUi.uic')

        New-UEAddin -AddinName 'UiAddin' -Template 'WithUi' -Module Model -CustomizationRootDirOverride $workspace -TemplatesDirOverride $templates

        Get-Content (Join-Path $workspace 'source' 'UiAddin' 'UiAddin.cs') -Raw | Should -Match 'class UiAddin'
        Get-Content (Join-Path $addins 'DesignAddins.xml') -Raw | Should -Match '<string>UiAddin</string>'
        Get-Content (Join-Path $addins 'DesignCustomization.xml') -Raw | Should -Match 'UiAddin\.uic'
    }

    It 'leaves registration unchanged for a template without a UIC file' {
        $template = Join-Path $templates 'Headless'
        New-Item $template -ItemType Directory | Out-Null
        'class Headless {}' | Set-Content (Join-Path $template 'Headless.cs')
        $beforeAddins = Get-Content (Join-Path $addins 'DesignAddins.xml') -Raw
        $beforeCustomization = Get-Content (Join-Path $addins 'DesignCustomization.xml') -Raw

        New-UEAddin -AddinName 'HeadlessAddin' -Template 'Headless' -Module Model -CustomizationRootDirOverride $workspace -TemplatesDirOverride $templates

        Get-Content (Join-Path $addins 'DesignAddins.xml') -Raw | Should -BeExactly $beforeAddins
        Get-Content (Join-Path $addins 'DesignCustomization.xml') -Raw | Should -BeExactly $beforeCustomization
        Test-Path (Join-Path $workspace 'source' 'HeadlessAddin' 'HeadlessAddin.cs') | Should -BeTrue
    }

    It 'finds packaged templates relative to the skill script' {
        $expectedTemplate = [System.IO.Path]::GetFullPath((Join-Path (Split-Path $scriptPath) '..' 'templates' 'PMLExtensionTemplate'))

        Copy-UEAddinTemplate -AddinName 'PackagedAddin' -Template 'PMLExtensionTemplate' -CustomizationRootDir $workspace

        Should -Invoke robocopy -Times 1 -Exactly -ParameterFilter {
            [System.IO.Path]::GetFullPath($SourceDirectory) -eq $expectedTemplate
        }
    }
}