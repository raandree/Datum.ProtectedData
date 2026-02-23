# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Add `build.yaml` Sampler pipeline configuration.
- Add `RequiredModules.psd1` for build-time dependency management.
- Add `build.ps1` and `Resolve-Dependency.ps1` standard Sampler bootstrap
  scripts.
- Add `GitVersion.yml` for automated semantic versioning.
- Add `azure-pipelines.yml` for Azure DevOps CI/CD with Build, Test (PS 5.1 +
  PS 7), and Deploy stages.
- Add `CHANGELOG.md` following Keep a Changelog format.
- Add `CONTRIBUTING.md` with contribution guidelines.
- Add `CODE_OF_CONDUCT.md` referencing DSC Community Code of Conduct.
- Add `SECURITY.md` for security vulnerability reporting.
- Add `codecov.yml` for code coverage reporting configuration.
- Add `.markdownlint.json` for Markdown linting rules.
- Add `.gitattributes` for line ending normalization.
- Add `.vscode/analyzersettings.psd1` for PSScriptAnalyzer configuration.
- Add `.vscode/launch.json` for PowerShell debugging.
- Add `.github/ISSUE_TEMPLATE/` with issue templates.
- Add `.github/PULL_REQUEST_TEMPLATE.md`.
- Add comprehensive `README.md` with badges, overview, installation,
  quick start, full function reference, and examples.

### Changed

- Migrate project scaffolding from legacy AppVeyor + InvokeBuild + PSDepend +
  PSDeploy to Sampler-based build system.
- Migrate CI/CD from AppVeyor to Azure Pipelines with Build, Test, and Deploy
  stages.
- Restructure repository from `Datum.ProtectedData/public/` layout to
  Sampler `source/Public/` layout.
- Replace `PSDepend.build.psd1` with `RequiredModules.psd1`.
- Replace `Deploy.PSDeploy.ps1` with Sampler publish tasks in `build.yaml`.
- Replace custom `.build.ps1` with standard Sampler `build.ps1`.
- Modernize module manifest with explicit `FunctionsToExport`,
  `PowerShellVersion`, `AliasesToExport`, `Tags`, `ProjectUri`, `LicenseUri`,
  and `IconUri`.
- Migrate `tests/QA/module.tests.ps1` to Pester 5 syntax using
  `BeforeDiscovery`/`BeforeAll` blocks, `-ForEach` instead of `foreach`
  loops, and update all legacy `Should` assertions to dash-parameter syntax.
- Migrate unit tests to Pester 5 syntax.
- Update `.gitignore` for Sampler output directory.
- Update `.vscode/settings.json` with full Sampler configuration.
- Add VSCode analyzer settings and launch configuration.

### Fixed

- Fix typo `'ByCertificae'` in `Unprotect-Datum.ps1` switch statement that
  prevented certificate-based decryption from working — change to
  `'ByCertificate'`.

### Removed

- Remove `#Requires -Modules ProtectedData` from individual function files
  (dependency is declared in module manifest `RequiredModules`).
- Remove legacy build files: `appveyor.yml`, `PSDepend.build.psd1`,
  `Deploy.PSDeploy.ps1`, `.build.ps1`, `.build/` directory.
- Remove old `Datum.ProtectedData/` source directory (replaced by `source/`).
