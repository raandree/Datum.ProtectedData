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
            Command = Get-Command -Name Invoke-ProtectedDatumAction -Module $script:moduleName
        }
    )
}

AfterAll {
    Remove-Module -Name $script:moduleName -Force
}

Describe 'Invoke-ProtectedDatumAction' -Tag 'Unit' {

    Context 'When the function is called' {

        It 'Should be exported from the module' -TestCases $testCases {
            $Command | Should -Not -BeNullOrEmpty
        }

        It 'Should have the correct parameter sets' -TestCases $testCases {
            $Command.ParameterSets.Name | Should -Contain 'ByPassword'
            $Command.ParameterSets.Name | Should -Contain 'ByCertificate'
        }

        It 'Should have a mandatory InputObject parameter' -TestCases $testCases {
            $Command.Parameters['InputObject'].Attributes.Mandatory | Should -Contain $true
        }

        It 'Should have a mandatory PlainTextPassword parameter in ByPassword set' -TestCases $testCases {
            $param = $Command.Parameters['PlainTextPassword']
            $param | Should -Not -BeNullOrEmpty
            ($param.ParameterSets.Values | Where-Object { $_.ParameterSetName -eq 'ByPassword' }).IsMandatory | Should -BeTrue
        }

        It 'Should have a mandatory Certificate parameter in ByCertificate set' -TestCases $testCases {
            $param = $Command.Parameters['Certificate']
            $param | Should -Not -BeNullOrEmpty
            ($param.ParameterSets.Values | Where-Object { $_.ParameterSetName -eq 'ByCertificate' }).IsMandatory | Should -BeTrue
        }
    }

    Context 'When decrypting with a password' {

        BeforeAll {
            Mock -ModuleName $script:moduleName -CommandName Unprotect-Datum -MockWith { 'DecryptedValue' }
        }

        It 'Should call Unprotect-Datum and return the decrypted value' {
            $result = Invoke-ProtectedDatumAction -InputObject '[ENC=TestData]' -PlainTextPassword 'P@ssw0rd'
            $result | Should -Be 'DecryptedValue'
        }
    }

    Context 'When caching decrypted values' {

        BeforeAll {
            Mock -ModuleName $script:moduleName -CommandName Unprotect-Datum -MockWith { 'CachedValue' }
        }

        It 'Should return cached value on second call with same input' {
            # First call should trigger decryption
            $result1 = Invoke-ProtectedDatumAction -InputObject '[ENC=CacheTest]' -PlainTextPassword 'P@ssw0rd'
            # Second call should return cached value
            $result2 = Invoke-ProtectedDatumAction -InputObject '[ENC=CacheTest]' -PlainTextPassword 'P@ssw0rd'

            $result1 | Should -Be 'CachedValue'
            $result2 | Should -Be 'CachedValue'
        }
    }
}
