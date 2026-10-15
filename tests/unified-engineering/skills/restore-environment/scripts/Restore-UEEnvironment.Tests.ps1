#Requires -Modules Pester

BeforeAll {
    $repoRoot = Join-Path $PSScriptRoot '..' '..' '..' '..' '..'
    $scriptPath = Join-Path $repoRoot 'plugins' 'unified-engineering' 'skills' 'restore-environment' 'scripts' 'Restore-UEEnvironment.ps1'
    . $scriptPath
}

Describe 'Restore-UEEnvironment skill script' -Tag 'Unit' {
    BeforeEach {
        $configPath = Join-Path $TestDrive 'environment.json'
        Mock Set-EnvironmentVariableUserAndSession {}
    }

    It 'applies each saved variable through the user-and-session setter' {
        @{
            CAF_ADDINS_PATH = 'saved-addins'
            UNIFIED_ENGINEERING_REFERENCE_PATH = 'saved-reference'
        } | ConvertTo-Json | Set-Content $configPath

        Restore-EnvironmentVariables -ConfigPath $configPath

        Should -Invoke Set-EnvironmentVariableUserAndSession -Times 2 -Exactly
        Should -Invoke Set-EnvironmentVariableUserAndSession -Times 1 -Exactly -ParameterFilter {
            $Name -eq 'CAF_ADDINS_PATH' -and $Value -eq 'saved-addins'
        }
        Should -Invoke Set-EnvironmentVariableUserAndSession -Times 1 -Exactly -ParameterFilter {
            $Name -eq 'UNIFIED_ENGINEERING_REFERENCE_PATH' -and $Value -eq 'saved-reference'
        }
    }

    It 'rejects a missing configuration before applying any variables' {
        { Restore-EnvironmentVariables -ConfigPath (Join-Path $TestDrive 'missing.json') } | Should -Throw '*configuration not found*'

        Should -Invoke Set-EnvironmentVariableUserAndSession -Times 0 -Exactly
    }

    It 'rejects malformed JSON before applying any variables' {
        '{ invalid JSON' | Set-Content $configPath

        { Restore-EnvironmentVariables -ConfigPath $configPath } | Should -Throw

        Should -Invoke Set-EnvironmentVariableUserAndSession -Times 0 -Exactly
    }
}