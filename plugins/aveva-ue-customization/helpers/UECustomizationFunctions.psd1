@{
    RootModule        = 'UECustomizationFunctions.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = '8e2f6b7f-5a50-4a1f-8b2e-3ce41d88a8a4'
    Author            = 'AVEVA'
    CompanyName       = 'AVEVA'
    Description       = 'Helper functions for setting up and managing the AVEVA Unified Engineering customization environment.'
    PowerShellVersion = '5.1'

    FunctionsToExport = @(
        'Get-VersionParts',
        'Find-RequiredFile',
        'Invoke-UEUnpack',
        'Restore-EnvironmentVariables',
        'Set-EnvironmentConfiguration',
        'Initialize-DirectoryStructure',
        'Install-UEFiles',
        'Update-SampleCsprojReferences',
        'Invoke-AddinCreation',
        'Invoke-EnvironmentCleanup',
        'Clear-UECustomizationEnvironment',
        'New-UEAddin',
        'Remove-UEAddin'
    )

    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
}
