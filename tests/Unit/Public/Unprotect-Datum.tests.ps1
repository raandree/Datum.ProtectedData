BeforeAll {
    $script:moduleName = 'Datum.ProtectedData'

    # If the module is not found, run the build task 'noop'.
    if (-not (Get-Module -Name $script:moduleName -ListAvailable))
    {
        # Redirect all streams to $null, except the error stream (stream 2)
        & "$PSScriptRoot/../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
    }

    # Re-import the module using force to get any code changes between runs.
    $importedModule = Import-Module -Name $script:moduleName -Force -PassThru -ErrorAction 'Stop'

    $testCases = @(
        @{
            Command = Get-Command -Name Unprotect-Datum -Module $script:moduleName
        }
    )
}

AfterAll {
    Remove-Module -Name $script:moduleName -Force
}

Describe 'Unprotect-Datum' -Tag 'Unit' {

    Context 'When the function is called' {

        It 'Should be exported from the module' -TestCases $testCases {
            $Command | Should -Not -BeNullOrEmpty
        }

        It 'Should have an OutputType of PSObject' -TestCases $testCases {
            $Command.OutputType.Type | Should -Contain ([PSObject])
        }

        It 'Should have a mandatory Base64Data parameter' -TestCases $testCases {
            $Command.Parameters['Base64Data'].Attributes.Mandatory | Should -Contain $true
        }

        It 'Should have the correct parameter sets' -TestCases $testCases {
            $Command.ParameterSets.Name | Should -Contain 'ByPassword'
            $Command.ParameterSets.Name | Should -Contain 'ByCertificate'
        }

        It 'Should accept a NoEncapsulation switch' -TestCases $testCases {
            $Command.Parameters['NoEncapsulation'].SwitchParameter | Should -BeTrue
        }
    }

    Context 'When decrypting with a password' {

        BeforeAll {
            Mock -ModuleName $script:moduleName -CommandName Unprotect-Data -MockWith { 'DecryptedSecret' }
        }

        It 'Should strip encapsulation and call Unprotect-Data' {
            # Create a valid base64 encoded CLIXML string for testing
            $testObj = 'TestValue'
            $xml = [System.Management.Automation.PSSerializer]::Serialize($testObj)
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($xml)
            $base64 = [System.Convert]::ToBase64String($bytes)
            $encapsulated = "[ENC=$base64]"

            $password = ConvertTo-SecureString -String 'P@ssw0rd' -AsPlainText -Force
            $result = Unprotect-Datum -Base64Data $encapsulated -Password $password

            Should -Invoke -ModuleName $script:moduleName -CommandName Unprotect-Data -Times 1
            $result | Should -Be 'DecryptedSecret'
        }

        It 'Should handle data without encapsulation when NoEncapsulation is specified' {
            $testObj = 'TestValue'
            $xml = [System.Management.Automation.PSSerializer]::Serialize($testObj)
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($xml)
            $base64 = [System.Convert]::ToBase64String($bytes)

            $password = ConvertTo-SecureString -String 'P@ssw0rd' -AsPlainText -Force
            $result = Unprotect-Datum -Base64Data $base64 -Password $password -NoEncapsulation

            Should -Invoke -ModuleName $script:moduleName -CommandName Unprotect-Data -Times 1
            $result | Should -Be 'DecryptedSecret'
        }
    }
}
