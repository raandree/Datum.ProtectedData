# Project Brief: Datum.ProtectedData Sampler Migration

## Project Identity

- **Name**: Datum.ProtectedData
- **Repository**: <https://github.com/raandree/Datum.ProtectedData> (assumed fork/maintainership)
- **Original Author**: Gael Colas
- **Current Maintainer**: Raimund Andree (raandree)
- **License**: MIT (Copyright 2018 Gael Colas)
- **Module GUID**: `132c634a-1fe1-40f7-b327-5e723a0b23b2`

## Purpose

Datum.ProtectedData is a Datum handler module that encrypts and decrypts secrets
in [Datum](https://github.com/gaelcolas/datum/) configuration data using Dave
Wyatt's [ProtectedData](https://www.powershellgallery.com/packages/ProtectedData)
module. It enables storing encrypted secrets directly in YAML/JSON/PSD1
configuration files used by DSC (Desired State Configuration).

## Core Goal

Migrate Datum.ProtectedData from its legacy build system (AppVeyor + InvokeBuild +
PSDepend + PSDeploy) to the modern **Sampler**-based scaffolding used by the DSC
Community. The reference project for this migration is
[Datum.InvokeCommand](https://github.com/raandree/Datum.InvokeCommand) at
`D:\Git\Datum.InvokeCommand`, which was upgraded to Sampler on 2026-02-23.

## Scope

1. Restructure the repository to the Sampler `source/` layout
2. Replace AppVeyor CI with Azure Pipelines
3. Replace PSDepend/PSDeploy with Sampler `RequiredModules.psd1` / `build.yaml`
4. Adopt GitVersion for automated semantic versioning
5. Modernize Pester tests from v4 to v5 syntax
6. Add community files (CHANGELOG, CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, etc.)
7. Improve documentation (README with badges, examples, architecture)
8. Add comprehensive comment-based help to all functions
9. Fix code quality issues (PSScriptAnalyzer compliance)

## Exported Functions

| Function                       | Purpose                                            |
| ------------------------------ | -------------------------------------------------- |
| `Invoke-ProtectedDatumAction`  | Decrypt data when the Datum handler is triggered    |
| `Protect-Datum`                | Encrypt an object into an encrypted string          |
| `Test-ProtectedDatumFilter`    | Filter to determine if data should trigger handler  |
| `Unprotect-Datum`              | Decrypt a previously encrypted object               |

## Dependencies

- **ProtectedData** module (Dave Wyatt) - required at runtime
