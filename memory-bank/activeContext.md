# Active Context

## Current State

Migration is **fully complete and verified**. All 75 tests pass (43 QA + 15 unit +
17 integration). The build succeeds with `./build.ps1 -Tasks test`. The repository
has been fully restructured from legacy to modern Sampler-based scaffolding.

## What Was Done

### Source Restructuring
- Moved 4 public functions from `Datum.ProtectedData/public/` to `source/Public/`
- Created modernized module manifest at `source/Datum.ProtectedData.psd1`
- Created empty `source/Datum.ProtectedData.psm1` for ModuleBuilder

### Build System
- Created `build.yaml`, `RequiredModules.psd1`, `GitVersion.yml`, `azure-pipelines.yml`
- Copied standard Sampler bootstrap: `build.ps1`, `Resolve-Dependency.ps1/.psd1`
- Build verified: module compiles to `output/builtModule/Datum.ProtectedData/0.2.0/`

### Tests
- Migrated QA module test to Pester 5 (`tests/QA/module.tests.ps1`) — 43 tests
- Created 4 Pester 5 unit tests in `tests/Unit/Public/` — 15 tests
- Created integration tests in `tests/Integration/` — 17 tests (real encrypt/decrypt)
- Fixed Pester mock issues: `-RemoveParameterValidation` for ProtectedData internals
- Fixed regex: `(?s)` dotall flag for multiline base64 matching

### Code Quality
- Fixed bug: `ByCertificae` -> `ByCertificate` in Unprotect-Datum.ps1
- Removed `#Requires -Modules ProtectedData` from source files

### Documentation
- Comprehensive README.md with badges, examples, function reference
- Updated `docs/about_Datum.ProtectedData.md` with real content
- Created CHANGELOG.md (imperative mood, Keep a Changelog 1.1.0 format)
- Created CONTRIBUTING.md, CODE_OF_CONDUCT.md, SECURITY.md

### Cleanup
- Removed: `appveyor.yml`, `Deploy.PSDeploy.ps1`, `PSDepend.build.psd1`, `.build.ps1`
- Removed: `.build/` directory, old `Datum.ProtectedData/` module directory

## Build Execution Pattern

To avoid freezing VSCode, run builds in a detached process:

```powershell
$logPath = Join-Path $PWD 'output\test.log'
Start-Process pwsh -ArgumentList @('-NoProfile','-NonInteractive','-Command',
  "Set-Location '$PWD'; .\build.ps1 -Tasks test *>&1 | Out-File '$logPath' -Encoding utf8")
# Poll: Get-Content $logPath -Tail 25
```

Skip `-ResolveDependency` if `output/RequiredModules/` already exists.

## Remaining Work

- Consider increasing `CodeCoverageThreshold` from 0 (currently disabled)
- Set up Azure Pipelines in Azure DevOps
- First PSGallery publish of v0.2.0
- Optionally add `ErrorAction` propagation for `Unprotect-Data` failures

## Key Decisions

- Module GUID preserved: `132c634a-1fe1-40f7-b327-5e723a0b23b2`
- GitVersion next-version: `0.2.0` (migration = minor bump)
- CodeCoverageThreshold: 0 (to be increased after baseline)
- Builds run detached to avoid VSCode freezes
- Integration tests use real ProtectedData module (no mocks)
