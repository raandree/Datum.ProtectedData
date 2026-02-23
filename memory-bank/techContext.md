# Technical Context

## Current Technology Stack (Legacy - To Be Replaced)

| Component           | Current                              | Target (Sampler)                   |
| ------------------- | ------------------------------------ | ---------------------------------- |
| Build system        | ~~InvokeBuild + custom `.build.ps1`~~  | Sampler + `build.ps1` ✅          |
| Dependencies        | ~~PSDepend (`PSDepend.build.psd1`)~~   | `RequiredModules.psd1` ✅         |
| Deployment          | ~~PSDeploy (`Deploy.PSDeploy.ps1`)~~   | Sampler publish tasks ✅           |
| CI/CD               | ~~AppVeyor (`appveyor.yml`)~~          | Azure Pipelines ✅                 |
| Test framework      | ~~Pester 4.10.1~~                      | Pester 5 ✅                        |
| Versioning          | ~~Manual (`0.0.1` hardcoded)~~         | GitVersion (automated) ✅          |
| Module builder      | ~~Custom merge in `.build/`~~          | ModuleBuilder via Sampler ✅       |
| Source layout        | ~~`Datum.ProtectedData/public/`~~     | `source/Public/` ✅               |

## Target Technology Stack (from Datum.InvokeCommand Reference)

### Build Infrastructure

- **build.ps1**: Sampler bootstrap script (543 lines, standard Sampler template)
- **build.yaml**: Pipeline/module configuration (replaces all `.build/*.ps1` tasks)
- **RequiredModules.psd1**: Declares build-time and runtime module dependencies
- **Resolve-Dependency.ps1 / .psd1**: Sampler dependency resolution scripts
- **GitVersion.yml**: Semantic versioning configuration

### Module Layout

`	ext
source/
  Public/           # Exported functions (one file per function)
  Private/          # Internal helper functions (optional for this module)
  en-US/            # Localized string resources
  Prefix.ps1        # Code prepended to the built .psm1 (module initialization)
  Datum.ProtectedData.psd1   # Module manifest (source version)
  Datum.ProtectedData.psm1   # Empty placeholder (built by ModuleBuilder)
`

### CI/CD Pipeline (Azure Pipelines)

- **Build stage**: GitVersion calculation, `build.ps1 -tasks pack`
- **Test stage**: Windows PS 5.1 + PS 7 (pwsh), publish test results
- **Deploy stage**: Publish to PSGallery + GitHub Release + Changelog PR

### Testing

- **tests/QA/module.tests.ps1**: Pester 5 module quality tests (PSSA, help, changelog)
- **tests/Unit/Public/**: Per-function unit tests
- **tests/Integration/**: Integration tests (if applicable)

## Development Setup

- PowerShell 5.1+ or PowerShell 7+
- Git
- Run `./build.ps1 -ResolveDependency` to bootstrap

## Key Dependencies

### Runtime

- `ProtectedData` module (Dave Wyatt) - core encryption/decryption

### Build-time (from Datum.InvokeCommand reference)

- InvokeBuild
- PSScriptAnalyzer
- Pester (latest, v5)
- Plaster
- ModuleBuilder
- ChangelogManagement
- Sampler
- Sampler.GitHubTasks
- MarkdownLinkCheck
- PlatyPS

## Technical Constraints

- Must support PowerShell 5.1 (Windows PowerShell) and PowerShell 7+
- Module GUID must remain `132c634a-1fe1-40f7-b327-5e723a0b23b2` for PSGallery compatibility
- `FunctionsToExport` must list explicit function names (not wildcards)
- `RequiredModules` must declare `ProtectedData` dependency

## Resolved Code Issues

1. **FIXED**: `Unprotect-Datum.ps1` typo `'ByCertificae'` -> `'ByCertificate'`
2. **FIXED**: `#Requires -Modules ProtectedData` removed from individual files
   (declared in module manifest `RequiredModules`)
3. **FIXED**: Module manifest now uses explicit `FunctionsToExport` list
4. **FIXED**: Unit tests replaced with real Pester 5 assertions + integration tests
5. **BY DESIGN**: `Invoke-ProtectedDatumAction.ps1` `PlainTextPassword` uses
   `[String]` because it receives args from Datum.yml YAML config
   (has `SuppressMessageAttribute` for PSSA)

## Known Behavioral Notes

1. `Protect-Data` (ProtectedData module) only accepts `String`, `SecureString`,
   `PSCredential`, or `Byte[]` — not arbitrary objects
2. `Unprotect-Data` wrong-password error is **non-terminating** — returns null
   instead of throwing, even with `-ErrorAction Stop` on `Unprotect-Datum`
3. `Protect-Data`/`Unprotect-Data` have `ValidateScript` attributes calling
   module-internal functions — Pester mocks require `-RemoveParameterValidation`
4. `Protect-Datum` wraps base64 at `MaxLineLength` (default 100) with `\r\n` —
   regex matching needs `(?s)` dotall flag

## Build Execution

- Run: `./build.ps1 -Tasks test` (build + test)
- Skip `-ResolveDependency` if `output/RequiredModules/` exists
- Output: `output/builtModule/Datum.ProtectedData/0.2.0/`
- Tests: `output/testResults/` (NUnit XML + Pester object)
- **Important**: Run detached from VSCode terminal to avoid freezes
