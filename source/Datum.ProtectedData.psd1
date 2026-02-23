@{

    RootModule        = 'Datum.ProtectedData.psm1'

    ModuleVersion     = '0.0.1'

    GUID              = '132c634a-1fe1-40f7-b327-5e723a0b23b2'

    Author            = 'Gael Colas'

    CompanyName       = 'Unknown'

    Copyright         = '(c) Gael Colas. All rights reserved.'

    Description       = 'Datum Handler module to encrypt and decrypt secrets in Datum using Dave Wyatt''s ProtectedData module'

    PowerShellVersion = '5.1'

    RequiredModules   = @('ProtectedData')

    FunctionsToExport = @(
        'Invoke-ProtectedDatumAction',
        'Protect-Datum',
        'Test-ProtectedDatumFilter',
        'Unprotect-Datum'
    )

    CmdletsToExport   = @()

    AliasesToExport    = @()

    PrivateData       = @{

        PSData = @{

            Tags         = @('DesiredStateConfiguration', 'DSC', 'DSCResource', 'Datum', 'ProtectedData', 'Encryption')

            LicenseUri   = 'https://github.com/raandree/Datum.ProtectedData/blob/master/LICENSE'

            ProjectUri   = 'https://github.com/raandree/Datum.ProtectedData'

            IconUri      = 'https://dsccommunity.org/images/DSC_Logo_300p.png'

            Prerelease   = ''

            ReleaseNotes = ''

        }

    }

}
