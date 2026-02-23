BeforeAll {
    $script:moduleName = 'Datum.ProtectedData'

    # If the module is not found, run the build task 'noop'.
    if (-not (Get-Module -Name $script:moduleName -ListAvailable))
    {
        # Redirect all streams to $null, except the error stream (stream 2)
        & "$PSScriptRoot/../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
    }

    Import-Module -Name $script:moduleName -Force -ErrorAction 'Stop'

    $script:testPassword = ConvertTo-SecureString -String 'IntegrationTestP@ss!' -AsPlainText -Force
}

AfterAll {
    Remove-Module -Name $script:moduleName -Force
}

Describe 'Protect-Datum and Unprotect-Datum round-trip' -Tag 'Integration' {

    Context 'When encrypting and decrypting a plain string' {

        It 'Should return the original string after round-trip' {
            $original = 'This is a secret message'

            $encrypted = Protect-Datum -InputObject $original -Password $script:testPassword
            $decrypted = Unprotect-Datum -Base64Data $encrypted -Password $script:testPassword

            $decrypted | Should -Be $original
        }

        It 'Should return the original string when using NoEncapsulation' {
            $original = 'NoEncapsulationTest'

            $encrypted = Protect-Datum -InputObject $original -Password $script:testPassword -NoEncapsulation
            $decrypted = Unprotect-Datum -Base64Data $encrypted -Password $script:testPassword -NoEncapsulation

            $decrypted | Should -Be $original
        }
    }

    Context 'When encrypting and decrypting a PSCredential' {

        It 'Should preserve username and password after round-trip' {
            $original = [PSCredential]::new(
                'TestUser',
                (ConvertTo-SecureString 'CredentialP@ss!' -AsPlainText -Force)
            )

            $encrypted = Protect-Datum -InputObject $original -Password $script:testPassword
            $decrypted = Unprotect-Datum -Base64Data $encrypted -Password $script:testPassword

            $decrypted | Should -BeOfType [PSCredential]
            $decrypted.UserName | Should -Be 'TestUser'
            $decrypted.GetNetworkCredential().Password | Should -Be 'CredentialP@ss!'
        }
    }

    Context 'When encrypting and decrypting a SecureString' {

        It 'Should preserve the secure string value after round-trip' {
            $original = ConvertTo-SecureString 'SecureValue123' -AsPlainText -Force

            $encrypted = Protect-Datum -InputObject $original -Password $script:testPassword
            $decrypted = Unprotect-Datum -Base64Data $encrypted -Password $script:testPassword

            $decrypted | Should -BeOfType [SecureString]
            $plainText = [System.Net.NetworkCredential]::new('', $decrypted).Password
            $plainText | Should -Be 'SecureValue123'
        }
    }

    Context 'When encrypting and decrypting a byte array' {

        It 'Should preserve all bytes after round-trip' {
            $original = [byte[]](0, 1, 2, 127, 128, 255)

            $encrypted = Protect-Datum -InputObject $original -Password $script:testPassword
            $decrypted = Unprotect-Datum -Base64Data $encrypted -Password $script:testPassword

            $decrypted | Should -HaveCount 6
            $decrypted[0] | Should -Be 0
            $decrypted[3] | Should -Be 127
            $decrypted[5] | Should -Be 255
        }
    }

    Context 'When using custom Header and Footer' {

        It 'Should encrypt and decrypt with custom encapsulation' {
            $original = 'CustomHeaderFooterTest'

            $encrypted = Protect-Datum -InputObject $original -Password $script:testPassword `
                -Header '[SECRET=' -Footer ']'
            $decrypted = Unprotect-Datum -Base64Data $encrypted -Password $script:testPassword `
                -Header '[SECRET=' -Footer ']'

            $decrypted | Should -Be $original
        }
    }

    Context 'When MaxLineLength controls output formatting' {

        It 'Should produce valid output regardless of line length' {
            $original = 'A' * 500  # Long string to force wrapping

            $encrypted = Protect-Datum -InputObject $original -Password $script:testPassword -MaxLineLength 50
            $decrypted = Unprotect-Datum -Base64Data $encrypted -Password $script:testPassword

            $decrypted | Should -Be $original
        }

        It 'Should produce single-line output when MaxLineLength is 0' {
            $original = 'SingleLineTest'

            $encrypted = Protect-Datum -InputObject $original -Password $script:testPassword -MaxLineLength 0

            # Strip encapsulation and check no newlines in the base64 body
            $body = $encrypted -replace '^\[ENC=' -replace '\]$'
            $body | Should -Not -Match "`r`n"

            $decrypted = Unprotect-Datum -Base64Data $encrypted -Password $script:testPassword
            $decrypted | Should -Be $original
        }
    }
}

Describe 'Test-ProtectedDatumFilter with real encrypted data' -Tag 'Integration' {

    Context 'When given output from Protect-Datum' {

        It 'Should return true for encrypted output with default encapsulation' {
            $encrypted = Protect-Datum -InputObject 'FilterTest' -Password $script:testPassword

            Test-ProtectedDatumFilter -InputObject $encrypted | Should -BeTrue
        }

        It 'Should return false for encrypted output without encapsulation' {
            $encrypted = Protect-Datum -InputObject 'FilterTest' -Password $script:testPassword -NoEncapsulation

            Test-ProtectedDatumFilter -InputObject $encrypted | Should -BeFalse
        }
    }
}

Describe 'Invoke-ProtectedDatumAction end-to-end' -Tag 'Integration' {

    Context 'When decrypting via the handler action' {

        It 'Should decrypt a string that was encrypted with Protect-Datum' {
            $original = 'HandlerActionTest'

            $encrypted = Protect-Datum -InputObject $original -Password $script:testPassword
            $decrypted = Invoke-ProtectedDatumAction -InputObject $encrypted -PlainTextPassword 'IntegrationTestP@ss!'

            $decrypted | Should -Be $original
        }

        It 'Should decrypt a credential that was encrypted with Protect-Datum' {
            $original = [PSCredential]::new(
                'Admin',
                (ConvertTo-SecureString 'S3cret!' -AsPlainText -Force)
            )

            $encrypted = Protect-Datum -InputObject $original -Password $script:testPassword
            $decrypted = Invoke-ProtectedDatumAction -InputObject $encrypted -PlainTextPassword 'IntegrationTestP@ss!'

            $decrypted | Should -BeOfType [PSCredential]
            $decrypted.UserName | Should -Be 'Admin'
            $decrypted.GetNetworkCredential().Password | Should -Be 'S3cret!'
        }
    }
}

Describe 'Negative test cases' -Tag 'Integration' {

    Context 'When decrypting with the wrong password' {

        It 'Should fail to decrypt and return null' {
            $encrypted = Protect-Datum -InputObject 'WrongPasswordTest' -Password $script:testPassword
            $wrongPassword = ConvertTo-SecureString -String 'WrongPassword' -AsPlainText -Force

            # Unprotect-Data may emit a non-terminating error (returns null) or
            # throw a terminating error depending on environment and PS edition.
            $decrypted = try
            {
                Unprotect-Datum -Base64Data $encrypted -Password $wrongPassword -ErrorAction SilentlyContinue
            }
            catch
            {
                $null
            }

            $decrypted | Should -BeNullOrEmpty
        }

        It 'Should not return the original value when using the wrong password' {
            $original = 'WrongPasswordValue'
            $encrypted = Protect-Datum -InputObject $original -Password $script:testPassword
            $wrongPassword = ConvertTo-SecureString -String 'WrongPassword' -AsPlainText -Force

            $decrypted = try
            {
                Unprotect-Datum -Base64Data $encrypted -Password $wrongPassword -ErrorAction SilentlyContinue
            }
            catch
            {
                $null
            }

            $decrypted | Should -Not -Be $original
        }
    }

    Context 'When decrypting invalid base64 data' {

        It 'Should throw an error for malformed input' {
            $bogus = '[ENC=NotValidBase64!!!]'

            { Unprotect-Datum -Base64Data $bogus -Password $script:testPassword } | Should -Throw
        }
    }

    Context 'When encrypting with an empty InputObject' {

        It 'Should reject empty string input' {
            { Protect-Datum -InputObject '' -Password $script:testPassword } | Should -Throw
        }

        It 'Should reject null input' {
            { Protect-Datum -InputObject $null -Password $script:testPassword } | Should -Throw
        }
    }
}
