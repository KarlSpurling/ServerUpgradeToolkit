@{
    RootModule        = 'FileSnapshot.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'b7c9c2e0-1c3a-4b8d-9b4f-123456789abc'
    Author            = 'Karl Spurling'
    CompanyName       = 'ServerUpgradeToolkit'
    Description       = 'Provides file snapshot and diffing utilities for pre-upgrade state capture.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Get-FileSnapshot',
        'Invoke-FileSnapshot',
        'Compare-FileSnapshots'
    )
}
