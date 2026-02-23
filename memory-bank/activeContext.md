# Active Context

## Current State

All migration phases are complete. The repository has been fully restructured from legacy
(AppVeyor + InvokeBuild + PSDepend + PSDeploy) to modern Sampler-based scaffolding.

## What Was Done

### Source Restructuring
- Moved 4 public functions from `Datum.ProtectedData/public/` to `source/Public/`
- Created modernized module manifest at `source/Datum.ProtectedData.psd1`
- Created empty `source/Datum.ProtectedData.psm1` for ModuleBuilder

### Build System
- Created `build.yaml`, `RequiredModules.psd1`, `GitVersion.yml`, `azure-pipelines.yml`
- Copied standard Sampler bootstrap: `build.ps1`, `Resolve-Dependency.ps1/.psd1`

### Tests
- Migrated QA module test to Pester 5 (`tests/QA/module.tests.ps1`)
- Created 4 Pester 5 unit tests in `tests/Unit/Public/`

### Code Quality
- Fixed bug: `ByCertificae` -> `ByCertificate` in Unprotect-Datum.ps1
- Removed `#Requires -Modules ProtectedData` from source files

### Documentation
- Comprehensive README.md with badges, examples, function reference
- Updated `docs/about_Datum.ProtectedData.md` with real content
- Created CHANGELOG.md, CONTRIBUTING.md, CODE_OF_CONDUCT.md, SECURITY.md

### Cleanup
- Removed: `appveyor.yml`, `Deploy.PSDeploy.ps1`, `PSDepend.build.psd1`, `.build.ps1`
- Removed: `.build/` directory, old `Datum.ProtectedData/` module directory

## Remaining Work

- Run `./build.ps1 -ResolveDependency` to verify the build works end-to-end
- Run full test suite and fix any failures
- Optionally improve code coverage

## Key Decisions

- Module GUID preserved: `132c634a-1fe1-40f7-b327-5e723a0b23b2`
- GitVersion next-version: `0.2.0` (migration = minor bump)
- CodeCoverageThreshold: 0 (to be increased after baseline)
