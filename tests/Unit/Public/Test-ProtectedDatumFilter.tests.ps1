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
            Command = Get-Command -Name Test-ProtectedDatumFilter -Module $script:moduleName
        }
    )
}

AfterAll {
    Remove-Module -Name $script:moduleName -Force
}

Describe 'Test-ProtectedDatumFilter' -Tag 'Unit' {

    Context 'When the function is called' {

        It 'Should be exported from the module' -TestCases $testCases {
            $Command | Should -Not -BeNullOrEmpty
        }

        It 'Should accept pipeline input' -TestCases $testCases {
            $Command.Parameters['InputObject'].Attributes.ValueFromPipeline | Should -Contain $true
        }
    }

    Context 'When testing encapsulated strings' {

        It 'Should return true for a properly encapsulated string' {
            $result = Test-ProtectedDatumFilter -InputObject '[ENC=ABC]'
            $result | Should -BeTrue
        }

        It 'Should return true for multiline encapsulated data' {
            $result = Test-ProtectedDatumFilter -InputObject "[ENC=QUJD`r`nREVG]"
            $result | Should -BeTrue
        }

        It 'Should return true for encapsulated string with special characters' {
            $result = Test-ProtectedDatumFilter -InputObject '[ENC=QUJD+/==]'
            $result | Should -BeTrue
        }
    }

    Context 'When testing non-encapsulated strings' {

        It 'Should return false for a plain string' {
            $result = Test-ProtectedDatumFilter -InputObject 'NotEncrypted'
            $result | Should -BeFalse
        }

        It 'Should return false for an empty string' {
            $result = Test-ProtectedDatumFilter -InputObject ''
            $result | Should -BeFalse
        }

        It 'Should return false for a string without proper header' {
            $result = Test-ProtectedDatumFilter -InputObject 'ABC]'
            $result | Should -BeFalse
        }

        It 'Should return false for a non-string object' {
            $result = Test-ProtectedDatumFilter -InputObject 42
            $result | Should -BeFalse
        }
    }

    Context 'When using the pipeline' {

        It 'Should accept pipeline input and return true' {
            $result = '[ENC=TestData]' | Test-ProtectedDatumFilter
            $result | Should -BeTrue
        }

        It 'Should accept pipeline input and return false' {
            $result = 'NotEncrypted' | Test-ProtectedDatumFilter
            $result | Should -BeFalse
        }
    }
}
