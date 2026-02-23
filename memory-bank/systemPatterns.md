# System Patterns

## Architecture

### Module Handler Pattern

Datum.ProtectedData follows the **Datum Handler** pattern:

1. **Filter function** (`Test-ProtectedDatumFilter`): Returns `True` when
   data matches `^\[ENC=[\w\W]*\]$`
2. **Action function** (`Invoke-ProtectedDatumAction`): Called by Datum when
   filter matches; delegates to `Unprotect-Datum`
3. **Utility functions**: `Protect-Datum` and `Unprotect-Datum` for
   encryption/decryption workflows

### Encryption Pipeline

`	ext
Protect-Datum:
  InputObject -> Protect-Data (ProtectedData module)
    -> PSSerializer.Serialize -> UTF8.GetBytes -> Base64
      -> Line-wrap -> Encapsulate with [ENC=...]=]

Unprotect-Datum:
  [ENC=base64blob] -> Strip header/footer
    -> FromBase64 -> UTF8.GetString -> PSSerializer.Deserialize
      -> Unprotect-Data (ProtectedData module) -> Original object
`

### Caching Pattern

`Invoke-ProtectedDatumAction` maintains a script-scope cache
(``) to avoid re-decrypting the same blob
multiple times during a single Datum resolution pass.

## Design Decisions

### Parameter Sets

Both `Protect-Datum` and `Unprotect-Datum` use parameter sets:

- **ByPassword**: For development/testing (uses `SecureString`)
- **ByCertificate**: For production (uses certificate thumbprint/file path)

`Invoke-ProtectedDatumAction` mirrors this but accepts `PlainTextPassword`
as a plain `[String]` because it receives args directly from Datum.yml YAML
configuration (where secure strings are not practical).

### Sampler Build Pattern (Target)

Following the Datum.InvokeCommand reference:

`	ext
build.ps1 (bootstrap) -> Resolve-Dependency.ps1 (install modules)
  -> InvokeBuild -> build.yaml tasks
    -> ModuleBuilder: source/ -> output/builtModule/
    -> Pester 5: tests/ -> output/testResults/
    -> GitVersion: semver from git history
    -> Publish: PSGallery + GitHub
`

### Key Build Configuration Keys (build.yaml)

- `BuildWorkflow`: Defines task chains (`.`, build, test, publish)
- `CopyPaths`: Extra folders to include in built module
- `Prefix`: Script prepended to the built `.psm1`
- `ModuleBuildTasks`: Sampler task modules to load
- `Pester`: Test configuration (paths, coverage threshold, output format)
- `GitHubConfig`: Release automation settings

## Component Relationships

`	ext
Datum.ProtectedData (this module)
  └── depends on: ProtectedData (Dave Wyatt)
  └── consumed by: Datum (gaelcolas)
       └── via DatumHandlers configuration in Datum.yml

Datum.InvokeCommand (sibling module, reference)
  └── depends on: DscResource.Common, Datum, Datum.ProtectedData
  └── consumed by: Datum
`

## Final Project Structure

```text
Datum.ProtectedData/
├── source/
│   ├── Public/
│   │   ├── Invoke-ProtectedDatumAction.ps1
│   │   ├── Protect-Datum.ps1
│   │   ├── Test-ProtectedDatumFilter.ps1
│   │   └── Unprotect-Datum.ps1
│   ├── Datum.ProtectedData.psd1
│   └── Datum.ProtectedData.psm1
├── tests/
│   ├── Integration/
│   │   └── Datum.ProtectedData.Integration.tests.ps1  (17 tests)
│   ├── QA/
│   │   └── module.tests.ps1                           (43 tests)
│   └── Unit/Public/
│       ├── Invoke-ProtectedDatumAction.tests.ps1       (2 tests)
│       ├── Protect-Datum.tests.ps1                     (2 tests)
│       ├── Test-ProtectedDatumFilter.tests.ps1         (9 tests)
│       └── Unprotect-Datum.tests.ps1                   (2 tests)
├── docs/
│   └── about_Datum.ProtectedData.md
├── .github/
│   ├── ISSUE_TEMPLATE/ (5 templates)
│   └── PULL_REQUEST_TEMPLATE.md
├── .vscode/ (settings, analyzer, launch)
├── memory-bank/ (7 files)
├── build.ps1, build.yaml, RequiredModules.psd1
├── Resolve-Dependency.ps1, Resolve-Dependency.psd1
├── azure-pipelines.yml, GitVersion.yml
├── CHANGELOG.md, CONTRIBUTING.md, CODE_OF_CONDUCT.md, SECURITY.md
├── README.md, LICENSE, .gitignore, .gitattributes
├── codecov.yml, .markdownlint.json
└── output/ (gitignored, build artifacts)
```

## Test Coverage Summary

| Test Suite | Count | Type | Mocked? |
| --- | --- | --- | --- |
| QA module tests | 43 | Quality/PSSA/Help | No |
| Integration tests | 17 | Real encrypt/decrypt round-trips | No |
| Invoke-ProtectedDatumAction | 2 | Parameter validation + mock | Yes |
| Protect-Datum | 2 | Parameter validation + mock | Yes |
| Test-ProtectedDatumFilter | 9 | Filter logic | No |
| Unprotect-Datum | 2 | Parameter validation + mock | Yes |
| **Total** | **75** | | |
