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

## File Mapping: Current -> Target

| Current Path                                       | Target Path                              |
| -------------------------------------------------- | ---------------------------------------- |
| `Datum.ProtectedData/public/*.ps1`               | `source/Public/*.ps1`                  |
| `Datum.ProtectedData/Datum.ProtectedData.psd1`   | `source/Datum.ProtectedData.psd1`      |
| `Datum.ProtectedData/Datum.ProtectedData.psm1`   | `source/Datum.ProtectedData.psm1`      |
| `Datum.ProtectedData/tests/QA/`                  | `tests/QA/`                            |
| `Datum.ProtectedData/tests/Unit/Public/`         | `tests/Unit/Public/`                   |
| `appveyor.yml`                                   | `azure-pipelines.yml`                  |
| `PSDepend.build.psd1`                            | `RequiredModules.psd1`                 |
| `Deploy.PSDeploy.ps1`                            | (removed - handled by build.yaml)        |
| `.build.ps1`                                     | `build.ps1` (Sampler standard)         |
| `.build/` (task scripts)                         | (removed - tasks from Sampler modules)   |
| (none)                                             | `build.yaml`                           |
| (none)                                             | `GitVersion.yml`                       |
| (none)                                             | `Resolve-Dependency.ps1`               |
| (none)                                             | `Resolve-Dependency.psd1`              |
| (none)                                             | `CHANGELOG.md`                         |
