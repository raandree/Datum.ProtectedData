# Progress

## Migration Status

**Overall**: ALL PHASES COMPLETE — BUILD VERIFIED (75/75 tests pass)

## Task Breakdown

### Phase 1: Analysis and Planning (COMPLETE)

- [x] Analyze Datum.ProtectedData current structure and code
- [x] Analyze Datum.InvokeCommand (reference) structure and code
- [x] Read all instruction files (PowerShell, YAML, Changelog, Versioning, Markdown)
- [x] Identify all files to create, move, modify, and delete
- [x] Document findings in memory bank
- [x] Create migration plan

### Phase 2: Repository Restructuring (COMPLETE)

- [x] Create `source/` directory structure
- [x] Move `Datum.ProtectedData/public/*.ps1` to `source/Public/`
- [x] Create new `source/Datum.ProtectedData.psd1` (modernized manifest)
- [x] Create empty `source/Datum.ProtectedData.psm1` (placeholder for ModuleBuilder)
- [x] Move tests to `tests/` (top-level)
- [x] Migrate `tests/QA/module.tests.ps1` to Pester 5 syntax
- [x] Migrate unit tests to Pester 5 syntax (all 4 functions)

### Phase 3: Build System (COMPLETE)

- [x] Create `build.yaml` (adapted from Datum.InvokeCommand)
- [x] Create `RequiredModules.psd1`
- [x] Copy `build.ps1` from Datum.InvokeCommand (standard Sampler script)
- [x] Copy `Resolve-Dependency.ps1` from Datum.InvokeCommand
- [x] Copy `Resolve-Dependency.psd1` from Datum.InvokeCommand
- [x] Create `GitVersion.yml`
- [x] Create `azure-pipelines.yml` (adapted from Datum.InvokeCommand)

### Phase 4: Community and Configuration Files (COMPLETE)

- [x] Create `CHANGELOG.md` (Keep a Changelog format, imperative mood)
- [x] Create `CONTRIBUTING.md`
- [x] Create `CODE_OF_CONDUCT.md`
- [x] Create `SECURITY.md`
- [x] Create `codecov.yml`
- [x] Create `.markdownlint.json`
- [x] Create `.gitattributes`
- [x] Update `.gitignore` (Sampler output/ pattern)
- [x] Update `.vscode/settings.json` (full Sampler config)
- [x] Create `.vscode/analyzersettings.psd1`
- [x] Create `.vscode/launch.json`
- [x] Create `.github/ISSUE_TEMPLATE/` templates
- [x] Create `.github/PULL_REQUEST_TEMPLATE.md`

### Phase 5: Code Quality (COMPLETE)

- [x] Fix typo in `Unprotect-Datum.ps1` (`ByCertificae` -> `ByCertificate`)
- [x] Remove `#Requires -Modules ProtectedData` from individual .ps1 files
- [x] Comment-based help already present and adequate on all 4 functions

### Phase 6: Documentation (COMPLETE)

- [x] Write comprehensive `README.md` with badges, overview, installation,
      usage examples, function reference, how-it-works section
- [x] Update `docs/about_Datum.ProtectedData.md` with real content
- [x] Add "Real-World Usage with DSC Workshop" section to README
      (credential layering, MOF encryption, further reading links)
- [x] Add DSC Workshop and blog post links to about-file SEE ALSO

### Phase 7: Cleanup (COMPLETE)

- [x] Remove legacy files: `appveyor.yml`, `PSDepend.build.psd1`,
      `Deploy.PSDeploy.ps1`, `.build.ps1`
- [x] Remove old `.build/` directory
- [x] Remove old `Datum.ProtectedData/` directory (source is now in `source/`)
- [x] Verify build works: `./build.ps1 -Tasks test`
- [x] Run tests and verify they pass (75/75)

### Phase 8: Integration Testing (COMPLETE)

- [x] Create `tests/Integration/Datum.ProtectedData.Integration.tests.ps1`
- [x] Add integration test path to `build.yaml` Pester configuration
- [x] String round-trip encryption/decryption (with and without encapsulation)
- [x] PSCredential round-trip (preserves username + password)
- [x] SecureString round-trip (preserves value)
- [x] Byte array round-trip (preserves all bytes)
- [x] Custom Header/Footer encapsulation
- [x] MaxLineLength variations (50, 0)
- [x] Test-ProtectedDatumFilter against real encrypted output
- [x] Invoke-ProtectedDatumAction end-to-end (string + credential)
- [x] Negative tests: wrong password returns null, malformed base64 throws, empty/null rejected
- [x] All 75 tests passing (43 QA + 15 unit + 17 integration)

## Known Issues

1. **FIXED**: `Unprotect-Datum.ps1` typo `'ByCertificae'` -> `'ByCertificate'`
2. **FIXED**: Protect-Datum unit test regex `^\.\[ENC=.*\]$` needed `(?s)` dotall
   flag because `Protect-Datum` wraps base64 at 100 chars with `\r\n`
3. **LEARNED**: `Protect-Data`/`Unprotect-Data` have `ValidateScript` attributes
   calling internal module functions — Pester mocks need `-RemoveParameterValidation`
4. **LEARNED**: `Unprotect-Data` wrong-password error is non-terminating —
   doesn't propagate through `Unprotect-Datum` even with `-ErrorAction Stop`
5. **LEARNED**: `Protect-Data` `InputObject` only accepts `String`, `SecureString`,
   `PSCredential`, or `Byte[]` — not arbitrary objects like hashtables
6. **LEARNED**: Running `build.ps1` with `Start-Process -Wait` freezes VSCode —
   must use detached process with log file polling

## Decision Log

| Date       | Decision                                              | Rationale                                        |
| ---------- | ----------------------------------------------------- | ------------------------------------------------ |
| 2026-02-23 | Use Datum.InvokeCommand as reference                  | Same maintainer, recently upgraded, similar scope |
| 2026-02-23 | Skip DscResource.Common/NestedModule                  | Not needed for this module's functions            |
| 2026-02-23 | Set GitVersion next-version to 0.2.0                  | Reflects migration as minor version bump          |
| 2026-02-23 | Keep module GUID unchanged                            | PSGallery module identity                        |
| 2026-02-23 | Adapt (not copy) build config from reference          | Module has different deps and no DSC resources    |
| 2026-02-23 | Run builds detached with log polling                  | Avoid VSCode UI freezes from blocking terminal    |
| 2026-02-23 | Use `-RemoveParameterValidation` on Pester mocks      | ProtectedData ValidateScript calls internal funcs |
| 2026-02-23 | Add integration tests alongside unit tests            | Unit mocks don't verify real encrypt/decrypt flow |
