# Product Context

## Why This Project Exists

Datum.ProtectedData solves the problem of securely storing secrets (credentials,
connection strings, API keys) within Datum configuration data files. In DSC
environments, configuration data is typically stored in plain-text YAML, JSON, or
PSD1 files. This module provides a handler mechanism that:

1. **Encrypts** sensitive data using certificate-based or password-based encryption
2. **Encapsulates** encrypted blobs with markers (`[ENC=...]=]`) so they can live
   inline in configuration files
3. **Decrypts** data on-the-fly when Datum resolves configuration values

## Problems It Solves

- Secrets in source control: encrypted blobs are safe to commit
- Certificate-based encryption for production, password-based for development/testing
- Seamless integration with the Datum resolution pipeline
- Caching of decrypted values for performance (``)

## How It Works

### Handler Registration (Datum.yml)

`yaml
DatumHandlers:
  Datum.ProtectedData::Invoke-ProtectedDatumAction:
    CommandOptions:
      Certificate: <thumbprint or path>
`

### Data Flow

1. User encrypts data with `Protect-Datum` producing `[ENC=<base64blob>]`
2. Encrypted string is stored in YAML/JSON/PSD1 config files
3. During Datum resolution, `Test-ProtectedDatumFilter` checks if data matches
   the `[ENC=...]=]` pattern
4. If matched, `Invoke-ProtectedDatumAction` calls `Unprotect-Datum` to decrypt
5. Decrypted value is returned to the Datum pipeline

## User Experience Goals

- Zero-friction encryption/decryption workflow
- Support both certificate and password-based scenarios
- Compatible with PowerShell 5.1 and PowerShell 7+
- Clear error messages when decryption fails
- Module should be installable from PSGallery with `Install-Module`

## Current State (Post-Migration)

- Module fully migrated to Sampler-based build system
- All 75 tests passing (QA + Unit + Integration)
- Comprehensive README with badges, examples, function reference
- CHANGELOG, CONTRIBUTING, CODE_OF_CONDUCT, SECURITY all present
- Azure Pipelines CI/CD configured (Build + Test PS5.1/PS7 + Deploy)
- GitVersion automated semantic versioning (next: 0.2.0)
- Integration tests verify real encrypt/decrypt round-trips
- Bug fixed: certificate-based decryption now works (`ByCertificae` typo)
