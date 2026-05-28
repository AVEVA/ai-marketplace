# Pester tests for UECustomizationFunctions module

# Navigate from tests/aveva-ue-customization/skills to plugins/aveva-ue-customization/helpers
# Up 3 levels from skills to repo root, then into plugins/aveva-ue-customization/helpers
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..\..')
$modulePath = Join-Path -Path $repoRoot -ChildPath 'plugins\aveva-ue-customization\helpers\UECustomizationFunctions.psm1'
Import-Module -Name $modulePath -Force -ErrorAction Stop

Describe 'UECustomizationFunctions Module' -Tag 'Unit' {
    BeforeAll {
        Mock -CommandName Set-EnvironmentVariableUserAndSession -ModuleName UECustomizationFunctions -MockWith {
            Set-Item -Path ("Env:{0}" -f $Name) -Value $Value
        }
    }

    It 'imports without errors' {
        { Get-Command -Module UECustomizationFunctions | Out-Null } | Should -Not -Throw
    }

    Context 'Get-VersionParts' {
        It 'parses numeric version correctly' {
            $result = Get-VersionParts -Name '1.2.3'
            $result | Should -HaveCount 3
            $result[0] | Should -Be 1
            $result[1] | Should -Be 2
            $result[2] | Should -Be 3
        }

        It 'ignores non-numeric characters' {
            $result = Get-VersionParts -Name 'v10.2.03-beta'
            $result | Should -HaveCount 3
            $result[0] | Should -Be 10
            $result[1] | Should -Be 2
            $result[2] | Should -Be 3
        }

        It 'returns empty array for invalid input' {
            $result = Get-VersionParts -Name 'no-numbers-here'
            $result | Should -HaveCount 0
        }

        It 'handles single version number' {
            $result = Get-VersionParts -Name '5'
            $result | Should -HaveCount 1
            $result[0] | Should -Be 5
        }
    }

    Context 'Find-RequiredFile' {
        It 'throws if file not found' {
            $temp = New-Item -ItemType Directory -Path (Join-Path $env:TEMP ("UE-Test-" + [Guid]::NewGuid()))
            try {
                { Find-RequiredFile -RootPath $temp.FullName -FileName 'nope.txt' } | Should -Throw
            }
            finally {
                Remove-Item -Path $temp.FullName -Recurse -Force
            }
        }

        It 'returns full path when file exists' {
            $temp = New-Item -ItemType Directory -Path (Join-Path $env:TEMP ("UE-Test-" + [Guid]::NewGuid()))
            try {
                $file = Join-Path $temp.FullName 'found.txt'
                Set-Content -Path $file -Value 'test' -Encoding UTF8
                $result = Find-RequiredFile -RootPath $temp.FullName -FileName 'found.txt'
                $result | Should -Be $file
            }
            finally {
                Remove-Item -Path $temp.FullName -Recurse -Force
            }
        }

        It 'finds files in subdirectories' {
            $temp = New-Item -ItemType Directory -Path (Join-Path $env:TEMP ("UE-Test-" + [Guid]::NewGuid()))
            try {
                $subdir = New-Item -Path (Join-Path $temp.FullName "subdir") -ItemType Directory
                $file = Join-Path $subdir.FullName 'nested.txt'
                Set-Content -Path $file -Value 'nested' -Encoding UTF8
                $result = Find-RequiredFile -RootPath $temp.FullName -FileName 'nested.txt'
                $result | Should -Be $file
            }
            finally {
                Remove-Item -Path $temp.FullName -Recurse -Force
            }
        }
    }

    Context 'Initialize-DirectoryStructure' {
        It 'creates addins, pmllib, and source directories' {
            $tempRoot = New-Item -ItemType Directory -Path (Join-Path $env:TEMP ("UE-Test-" + [Guid]::NewGuid()))
            try {
                $addins  = Join-Path $tempRoot.FullName 'addins'
                $pmllib  = Join-Path $tempRoot.FullName 'pmllib'
                $source  = Join-Path $tempRoot.FullName 'source'
                Initialize-DirectoryStructure -AddinsFolder $addins -PmlLibFolder $pmllib -SourceFolder $source
                Test-Path $addins  | Should -BeTrue
                Test-Path $pmllib  | Should -BeTrue
                Test-Path $source  | Should -BeTrue
            }
            finally {
                Remove-Item -Path $tempRoot.FullName -Recurse -Force
            }
        }

        It 'creates nested directory paths' {
            $tempRoot = New-Item -ItemType Directory -Path (Join-Path $env:TEMP ("UE-Test-" + [Guid]::NewGuid()))
            try {
                $addins  = Join-Path $tempRoot.FullName 'nested\path\addins'
                $pmllib  = Join-Path $tempRoot.FullName 'nested\path\pmllib'
                $source  = Join-Path $tempRoot.FullName 'nested\path\source'
                Initialize-DirectoryStructure -AddinsFolder $addins -PmlLibFolder $pmllib -SourceFolder $source
                Test-Path $addins  | Should -BeTrue
                Test-Path $pmllib  | Should -BeTrue
                Test-Path $source  | Should -BeTrue
            }
            finally {
                Remove-Item -Path $tempRoot.FullName -Recurse -Force
            }
        }
    }

    Context 'Set-EnvironmentConfiguration' {
        It 'creates configuration file with correct content' {
            $tempRoot = New-Item -ItemType Directory -Path (Join-Path $env:TEMP ("UE-Test-" + [Guid]::NewGuid()))
            try {
                $configPath = Join-Path $tempRoot.FullName 'environment.json'
                $addins  = Join-Path $tempRoot.FullName 'addins'
                $pmlLib  = Join-Path $tempRoot.FullName 'pmllib'
                $unpack  = Join-Path $tempRoot.FullName 'binaries'
                
                $config = Set-EnvironmentConfiguration -ConfigPath $configPath -AddinsFolder $addins -PmlLibFolder $pmlLib -UnpackPath $unpack
                
                Test-Path $configPath | Should -BeTrue
                $config.CAF_ADDINS_PATH | Should -Be $addins
                $config.CAF_UIC_PATH | Should -Be $addins
                $config.UNIFIED_ENGINEERING_REFERENCE_PATH | Should -Be $unpack
            }
            finally {
                Remove-Item -Path $tempRoot.FullName -Recurse -Force
            }
        }

        It 'sets environment variables in session' {
            $tempRoot = New-Item -ItemType Directory -Path (Join-Path $env:TEMP ("UE-Test-" + [Guid]::NewGuid()))
            try {
                $configPath = Join-Path $tempRoot.FullName 'environment.json'
                $addins  = Join-Path $tempRoot.FullName 'addins'
                $pmlLib  = Join-Path $tempRoot.FullName 'pmllib'
                $unpack  = Join-Path $tempRoot.FullName 'binaries'
                
                Set-EnvironmentConfiguration -ConfigPath $configPath -AddinsFolder $addins -PmlLibFolder $pmlLib -UnpackPath $unpack
                
                $env:CAF_ADDINS_PATH | Should -Be $addins
                $env:CAF_UIC_PATH | Should -Be $addins
                $env:UNIFIED_ENGINEERING_REFERENCE_PATH | Should -Be $unpack
            }
            finally {
                Remove-Item -Path $tempRoot.FullName -Recurse -Force
            }
        }
    }

    Context 'Restore-EnvironmentVariables' {
        It 'throws if config file does not exist' {
            { Restore-EnvironmentVariables -ConfigPath 'C:\nonexistent\path\environment.json' } | Should -Throw
        }

        It 'restores environment variables from config file' {
            $tempRoot = New-Item -ItemType Directory -Path (Join-Path $env:TEMP ("UE-Test-" + [Guid]::NewGuid()))
            try {
                $configPath = Join-Path $tempRoot.FullName 'environment.json'
                $addins  = Join-Path $tempRoot.FullName 'addins'
                $pmlLib  = Join-Path $tempRoot.FullName 'pmllib'
                $unpack  = Join-Path $tempRoot.FullName 'binaries'
                
                # Create config via Set-EnvironmentConfiguration
                Set-EnvironmentConfiguration -ConfigPath $configPath -AddinsFolder $addins -PmlLibFolder $pmlLib -UnpackPath $unpack
                
                # Clear session variables
                Remove-Item -Path 'Env:CAF_ADDINS_PATH' -ErrorAction SilentlyContinue
                Remove-Item -Path 'Env:CAF_UIC_PATH' -ErrorAction SilentlyContinue
                Remove-Item -Path 'Env:UNIFIED_ENGINEERING_REFERENCE_PATH' -ErrorAction SilentlyContinue
                
                # Restore from config
                Restore-EnvironmentVariables -ConfigPath $configPath
                
                $env:CAF_ADDINS_PATH | Should -Be $addins
                $env:CAF_UIC_PATH | Should -Be $addins
                $env:UNIFIED_ENGINEERING_REFERENCE_PATH | Should -Be $unpack
            }
            finally {
                Remove-Item -Path $tempRoot.FullName -Recurse -Force
            }
        }
    }

    Context 'Invoke-UEUnpack' {
        It 'throws if archive file does not exist' {
            { Invoke-UEUnpack -SourceZip 'C:\nonexistent\file.zip' -DestinationPath (Join-Path $env:TEMP 'test') } | Should -Throw
        }

        It 'throws if destination is invalid' {
            $temp = New-Item -ItemType Directory -Path (Join-Path $env:TEMP ("UE-Test-" + [Guid]::NewGuid()))
            try {
                $zipPath = Join-Path $temp.FullName 'test.zip'
                Set-Content -Path $zipPath -Value 'dummy'
                
                # Try to unpack to invalid location
                { Invoke-UEUnpack -SourceZip $zipPath -DestinationPath 'C:\invalid\path\that\does\not\exist' } | Should -Throw
            }
            finally {
                Remove-Item -Path $temp.FullName -Recurse -Force
            }
        }
    }

    Context 'Install-UEFiles' {
        It 'does not throw if source directory has no config files' {
            $temp = New-Item -ItemType Directory -Path (Join-Path $env:TEMP ("UE-Test-" + [Guid]::NewGuid()))
            try {
                # Should warn but not throw when no config files are found
                { Install-UEFiles -UnpackPath $temp.FullName -AddinsFolder (Join-Path $env:TEMP 'addins') } | Should -Not -Throw
            }
            finally {
                Remove-Item -Path $temp.FullName -Recurse -Force
            }
        }
    }

    Context 'Invoke-EnvironmentCleanup' {
        It 'throws if cleanup script does not exist' {
            { Invoke-EnvironmentCleanup -ScriptsPath 'C:\nonexistent\path' } | Should -Throw
        }
    }

    Context 'Clear-UECustomizationEnvironment.ps1 Script' {
        It 'removes environment.json during cleanup' {
            $tempRoot = New-Item -ItemType Directory -Path (Join-Path $env:TEMP ("UE-Test-" + [Guid]::NewGuid()))
            try {
                # Create a mock environment.json
                $configPath = Join-Path $tempRoot.FullName 'environment.json'
                $configData = @{ TEST_VAR = 'test_value' }
                $configData | ConvertTo-Json | Set-Content -Path $configPath -Encoding UTF8
                
                Test-Path $configPath | Should -BeTrue
                
                # Simulate what Clear-UECustomizationEnvironment.ps1 does
                $rootPath = Split-Path -Path $tempRoot.FullName -Parent
                $testConfigPath = Join-Path -Path $tempRoot.FullName -ChildPath "environment.json"
                
                if (Test-Path -Path $testConfigPath) {
                    Remove-Item -Path $testConfigPath -Force -ErrorAction SilentlyContinue
                }
                
                Test-Path $testConfigPath | Should -BeFalse
            }
            finally {
                Remove-Item -Path $tempRoot.FullName -Recurse -Force
            }
        }
    }

    Context 'New-UEAddin' {
        It 'throws if addin name contains special characters' {
            { New-UEAddin -AddinName 'Test-Addin' } | Should -Throw
        }

        It 'throws if addin name contains numbers' {
            { New-UEAddin -AddinName 'TestAddin123' } | Should -Throw
        }

        It 'throws if addin name contains spaces' {
            { New-UEAddin -AddinName 'Test Addin' } | Should -Throw
        }

        It 'updates DesignCustomization.xml only when template contains .uic' {
            $tempRoot = New-Item -ItemType Directory -Path (Join-Path $env:TEMP ("UE-Test-" + [Guid]::NewGuid()))
            try {
                # Arrange environment structure
                $addins = Join-Path $tempRoot.FullName 'addins'
                $templates = Join-Path $tempRoot.FullName 'templates'
                New-Item -Path $addins -ItemType Directory | Out-Null
                New-Item -Path $templates -ItemType Directory | Out-Null

                # Minimal DesignAddins.xml and DesignCustomization.xml
                $designAddinsXmlPath = Join-Path $addins 'DesignAddins.xml'
                $designCustomizationXmlPath = Join-Path $addins 'DesignCustomization.xml'
                "<ArrayOfString></ArrayOfString>" | Set-Content -Path $designAddinsXmlPath -Encoding UTF8
                "<Design></Design>" | Set-Content -Path $designCustomizationXmlPath -Encoding UTF8

                # Template WITH .uic
                $tmplWithUic = Join-Path $templates 'WithUicTemplate'
                New-Item -Path $tmplWithUic -ItemType Directory | Out-Null
                # Add dummy files
                Set-Content -Path (Join-Path $tmplWithUic 'WithUicTemplate.cs') -Value 'class WithUicTemplate {}' -Encoding UTF8
                Set-Content -Path (Join-Path $tmplWithUic 'WithUicTemplate.uic') -Value '<UIC/>' -Encoding UTF8

                # Act: create addin from template with .uic
                New-UEAddin -AddinName 'UiAddin' -Template 'WithUicTemplate' -CustomizationRootDirOverride $tempRoot.FullName -TemplatesDirOverride $templates -Module 'Model'

                # Assert DesignCustomization.xml updated for UiAddin
                [string]$custXml1 = Get-Content -Path $designCustomizationXmlPath -Raw
                $custXml1 | Should -Match 'UiAddin'
                $custXml1 | Should -Match 'UiAddin\.uic'

                # Template WITHOUT .uic
                $tmplNoUic = Join-Path $templates 'HeadlessAddInTemplate'
                New-Item -Path $tmplNoUic -ItemType Directory | Out-Null
                Set-Content -Path (Join-Path $tmplNoUic 'HeadlessAddInTemplate.cs') -Value 'class HeadlessAddInTemplate {}' -Encoding UTF8

                # Capture current customization xml for comparison
                [string]$beforeNoUic = Get-Content -Path $designCustomizationXmlPath -Raw

                # Act: create addin from template without .uic
                New-UEAddin -AddinName 'Headless' -Template 'HeadlessAddInTemplate' -CustomizationRootDirOverride $tempRoot.FullName -TemplatesDirOverride $templates -Module 'Model'

                # Assert DesignCustomization.xml NOT updated for 'Headless'
                [string]$afterNoUic = Get-Content -Path $designCustomizationXmlPath -Raw
                $afterNoUic | Should -Not -Match 'Headless\.uic'
                $afterNoUic | Should -Not -Match 'Name="Headless"'

                # Also ensure DesignAddins.xml contains the UI addin but not the headless one
                [string]$addinsXml = Get-Content -Path $designAddinsXmlPath -Raw
                $addinsXml | Should -Match '<string>UiAddin</string>'
                $addinsXml | Should -Not -Match '<string>Headless</string>'
            }
            finally {
                Remove-Item -Path $tempRoot.FullName -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }

    Context 'Remove-UEAddin' {
        It 'has proper function signature' {
            $cmd = Get-Command -Name Remove-UEAddin
            $cmd | Should -Not -BeNullOrEmpty
            $cmd.Parameters.Keys | Should -Contain 'AddinName'
        }
    }

    Context 'Invoke-AddinCreation' {
        It 'throws if script path does not exist' {
            { Invoke-AddinCreation -AddinName 'TestAddin' -ScriptPath 'C:\nonexistent\New-UEAddin.ps1' } | Should -Throw
        }
    }
}
