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
            Command = Get-Command -Name Protect-Datum -Module $script:moduleName
        }
    )
}

AfterAll {
    Remove-Module -Name $script:moduleName -Force
}

Describe 'Protect-Datum' -Tag 'Unit' {

    Context 'When the function is called' {

        It 'Should be exported from the module' -TestCases $testCases {
            $Command | Should -Not -BeNullOrEmpty
        }

        It 'Should have an OutputType of String' -TestCases $testCases {
            $Command.OutputType.Type | Should -Contain ([string])
        }

        It 'Should have a mandatory InputObject parameter' -TestCases $testCases {
            $Command.Parameters['InputObject'].Attributes.Mandatory | Should -Contain $true
        }

        It 'Should have the correct parameter sets' -TestCases $testCases {
            $Command.ParameterSets.Name | Should -Contain 'ByPassword'
            $Command.ParameterSets.Name | Should -Contain 'ByCertificate'
        }

        It 'Should have a DefaultValue of 100 for MaxLineLength' -TestCases $testCases {
            $Command.Parameters['MaxLineLength'].ParameterType | Should -Be ([int])
        }

        It 'Should accept a NoEncapsulation switch' -TestCases $testCases {
            $Command.Parameters['NoEncapsulation'].SwitchParameter | Should -BeTrue
        }
    }

    Context 'When protecting data with a password' {

        BeforeAll {
            Mock -ModuleName $script:moduleName -CommandName Protect-Data -RemoveParameterValidation 'InputObject' -MockWith { 'ProtectedBlob' }
        }

        It 'Should return an encapsulated string by default' {
            $password = ConvertTo-SecureString -String 'P@ssw0rd' -AsPlainText -Force
            $result = Protect-Datum -InputObject 'TestSecret' -Password $password

            $result | Should -Match '(?s)^\[ENC=.*\]$'
        }

        It 'Should return a string without encapsulation when NoEncapsulation is used' {
            $password = ConvertTo-SecureString -String 'P@ssw0rd' -AsPlainText -Force
            $result = Protect-Datum -InputObject 'TestSecret' -Password $password -NoEncapsulation

            $result | Should -Not -Match '^\[ENC='
            $result | Should -Not -Match '\]$'
        }
    }
}
