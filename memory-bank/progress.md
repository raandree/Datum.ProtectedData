# Progress

## Migration Status

**Overall**: Phase 1 - Analysis Complete | Phase 2 - Implementation Not Started

## Task Breakdown

### Phase 1: Analysis and Planning (COMPLETE)

- [x] Analyze Datum.ProtectedData current structure and code
- [x] Analyze Datum.InvokeCommand (reference) structure and code
- [x] Read all instruction files (PowerShell, YAML, Changelog, Versioning, Markdown)
- [x] Identify all files to create, move, modify, and delete
- [x] Document findings in memory bank
- [x] Create migration plan

### Phase 2: Repository Restructuring

- [ ] Create `source/` directory structure
- [ ] Move `Datum.ProtectedData/public/*.ps1` to `source/Public/`
- [ ] Create new `source/Datum.ProtectedData.psd1` (modernized manifest)
- [ ] Create empty `source/Datum.ProtectedData.psm1` (placeholder for ModuleBuilder)
- [ ] Move tests to `tests/` (top-level)
- [ ] Migrate `tests/QA/module.tests.ps1` to Pester 5 syntax
- [ ] Migrate unit tests to Pester 5 syntax

### Phase 3: Build System

- [ ] Create `build.yaml` (adapted from Datum.InvokeCommand)
- [ ] Create `RequiredModules.psd1`
- [ ] Copy `build.ps1` from Datum.InvokeCommand (standard Sampler script)
- [ ] Copy `Resolve-Dependency.ps1` from Datum.InvokeCommand
- [ ] Copy `Resolve-Dependency.psd1` from Datum.InvokeCommand
- [ ] Create `GitVersion.yml`
- [ ] Create `azure-pipelines.yml` (adapted from Datum.InvokeCommand)

### Phase 4: Community and Configuration Files

- [ ] Create `CHANGELOG.md` (Keep a Changelog format)
- [ ] Create `CONTRIBUTING.md`
- [ ] Create `CODE_OF_CONDUCT.md`
- [ ] Create `SECURITY.md`
- [ ] Create `codecov.yml`
- [ ] Create `.markdownlint.json`
- [ ] Create `.gitattributes`
- [ ] Update `.gitignore` (Sampler output/ pattern)
- [ ] Update `.vscode/settings.json` (full Sampler config)
- [ ] Create `.vscode/analyzersettings.psd1`
- [ ] Create `.vscode/launch.json`
- [ ] Create `.github/ISSUE_TEMPLATE/` templates
- [ ] Create `.github/PULL_REQUEST_TEMPLATE.md`

### Phase 5: Code Quality

- [ ] Fix typo in `Unprotect-Datum.ps1` (`ByCertificae` -> `ByCertificate`)
- [ ] Remove `#Requires -Modules ProtectedData` from individual .ps1 files
- [ ] Improve comment-based help on all functions
- [ ] Address PSScriptAnalyzer warnings
- [ ] Review and improve parameter validation

### Phase 6: Documentation

- [ ] Write comprehensive `README.md` with badges, overview, installation,
      usage examples, function reference
- [ ] Create `docs/` content (architecture, getting started, troubleshooting)
- [ ] Update `about_Datum.ProtectedData.md` with real content

### Phase 7: Cleanup

- [ ] Remove legacy files: `appveyor.yml`, `PSDepend.build.psd1`,
      `Deploy.PSDeploy.ps1`, `.build.ps1`, `.build/` directory
- [ ] Remove old `Datum.ProtectedData/` directory (after source moved)
- [ ] Verify build works: `./build.ps1 -ResolveDependency`
- [ ] Run tests and verify they pass

## Known Issues

1. **Bug**: `Unprotect-Datum.ps1` has typo `'ByCertificae'` in switch statement
   (certificate-based decryption is silently broken)
2. **Placeholder tests**: Most unit tests assert `True | Should -Be True`
3. **No real integration tests**: No tests that actually encrypt/decrypt data

## Decision Log

| Date       | Decision                                              | Rationale                                        |
| ---------- | ----------------------------------------------------- | ------------------------------------------------ |
| 2026-02-23 | Use Datum.InvokeCommand as reference                  | Same maintainer, recently upgraded, similar scope |
| 2026-02-23 | Skip DscResource.Common/NestedModule                  | Not needed for this module's functions            |
| 2026-02-23 | Set GitVersion next-version to 0.2.0                  | Reflects migration as minor version bump          |
| 2026-02-23 | Keep module GUID unchanged                            | PSGallery module identity                        |
| 2026-02-23 | Adapt (not copy) build config from reference          | Module has different deps and no DSC resources    |
