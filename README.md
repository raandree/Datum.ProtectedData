# Datum.ProtectedData

[![Build Status](https://dev.azure.com/RaijinCluster/Datum.ProtectedData/_apis/build/status/raandree.Datum.ProtectedData?branchName=main)](https://dev.azure.com/RaijinCluster/Datum.ProtectedData/_build/latest?definitionId=8&branchName=main)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/Datum.ProtectedData)](https://www.powershellgallery.com/packages/Datum.ProtectedData)
[![License](https://img.shields.io/github/license/raandree/Datum.ProtectedData)](https://github.com/raandree/Datum.ProtectedData/blob/main/LICENSE)

A [Datum](https://github.com/gaelcolas/datum/) handler module that encrypts and decrypts secrets in Datum configuration data using Dave Wyatt's [ProtectedData](https://github.com/dlwyatt/ProtectedData) module.

## Overview

**Datum.ProtectedData** extends the [Datum](https://github.com/gaelcolas/datum/) configuration management framework by providing encryption and decryption of sensitive data (credentials, secure strings, plain strings) stored in YAML, JSON, or PSD1 configuration files.

This is particularly useful for:

- **Securing credentials** in Datum configuration files without exposing plain-text passwords
- **Encrypting any object** (credentials, secure strings, strings) into a portable base64-encoded text block
- **Certificate-based encryption** for production environments using the ProtectedData module
- **Password-based encryption** for development and testing scenarios
- **Automatic decryption** during Datum resolution via handler registration

For the Datum framework documentation, architecture overview, and handler concepts, refer to the [Datum project](https://github.com/gaelcolas/datum/).

## Requirements

- **PowerShell** 5.1 or later (Windows PowerShell or PowerShell 7+)
- **[Datum](https://github.com/gaelcolas/datum/)** module
- **[ProtectedData](https://github.com/dlwyatt/ProtectedData)** module (Dave Wyatt)

## Installation

Install from the PowerShell Gallery:

```powershell
Install-Module -Name Datum.ProtectedData
```

Or with PowerShellGet v3+:

```powershell
Install-PSResource -Name Datum.ProtectedData
```

## Quick Start

### 1. Register the Handler in Datum.yml

Add the `Datum.ProtectedData` handler to your `Datum.yml` configuration file:

**Using certificate-based decryption (recommended for production):**

```yaml
DatumHandlers:
  Datum.ProtectedData::ProtectedDatum:
    CommandOptions:
      Certificate: 3A7B68D3D4C63E2F2D91F5C5C6A4B9F1D8A3B7C5
```

**Using password-based decryption (for development/testing only):**

```yaml
DatumHandlers:
  Datum.ProtectedData::ProtectedDatum:
    CommandOptions:
      PlainTextPassword: P@ssw0rd
```

### 2. Encrypt Secrets

Use `Protect-Datum` to encrypt sensitive data:

**Encrypt a credential object:**

```powershell
$credential = Get-Credential
$password = ConvertTo-SecureString -String 'P@ssw0rd' -AsPlainText -Force
Protect-Datum -InputObject $credential -Password $password
```

Output:

```text
[ENC=PE9ianMgVmVyc2lvbj0iMS4xLj...
QUJDREVG...
PC9PYmpzPg==]
```

**Encrypt with a certificate:**

```powershell
Protect-Datum -InputObject 'MySecret' -Certificate '3A7B68D3D4C63E2F2D91F5C5C6A4B9F1D8A3B7C5'
```

### 3. Store the Encrypted Value in YAML

Paste the encrypted output into your Datum YAML file:

```yaml
Credentials:
  DomainAdmin: >-
    [ENC=PE9ianMgVmVyc2lvbj0iMS4xLj...
    QUJDREVG...
    PC9PYmpzPg==]
```

### 4. Datum Resolves Automatically

When Datum resolves configuration data, the handler automatically detects the `[ENC=...]` pattern, decrypts it, and returns the original object:

```powershell
$datum = New-DatumStructure -DefinitionFile '.\Datum.yml'
$credential = $datum.Credentials.DomainAdmin
# $credential is now a [PSCredential] object
```

## Functions

### Protect-Datum

Encrypts an object into a base64-encoded string ready for use in text-based configuration files.

```powershell
Protect-Datum -InputObject <PSObject> -Password <SecureString> [-MaxLineLength <Int>] [-Header <String>] [-Footer <String>] [-NoEncapsulation]
Protect-Datum -InputObject <PSObject> -Certificate <String> [-MaxLineLength <Int>] [-Header <String>] [-Footer <String>] [-NoEncapsulation]
```

| Parameter | Description |
|---|---|
| `-InputObject` | The object to encrypt (credential, secure string, or any serializable object) |
| `-Password` | SecureString password for encryption (**testing only**) |
| `-Certificate` | Certificate thumbprint, file path, or cert provider path |
| `-MaxLineLength` | Line length for wrapping the base64 output (default: 100) |
| `-Header` | Encapsulation header (default: `[ENC=`) |
| `-Footer` | Encapsulation footer (default: `]`) |
| `-NoEncapsulation` | Omit header/footer wrapping |

### Unprotect-Datum

Decrypts a previously encrypted base64-encoded string back to the original object.

```powershell
Unprotect-Datum -Base64Data <String> -Password <SecureString> [-Header <String>] [-Footer <String>] [-NoEncapsulation]
Unprotect-Datum -Base64Data <String> -Certificate <String> [-Header <String>] [-Footer <String>] [-NoEncapsulation]
```

| Parameter | Description |
|---|---|
| `-Base64Data` | The encrypted base64-encoded string |
| `-Password` | SecureString password for decryption (**testing only**) |
| `-Certificate` | Certificate for decryption (must contain private key) |
| `-Header` | Encapsulation header to strip (default: `[ENC=`) |
| `-Footer` | Encapsulation footer to strip (default: `]`) |
| `-NoEncapsulation` | Data is not encapsulated, skip header/footer stripping |

### Test-ProtectedDatumFilter

Tests whether a data value matches the encrypted data pattern. Used by Datum to determine when to trigger the handler.

```powershell
Test-ProtectedDatumFilter -InputObject <Object>
'[ENC=data]' | Test-ProtectedDatumFilter
```

Returns `$true` if the input is a string matching `^\[ENC=[\w\W]*\]$`.

### Invoke-ProtectedDatumAction

The action function called by Datum when the filter matches. Decrypts the data and caches results for performance.

```powershell
Invoke-ProtectedDatumAction -InputObject <String> -PlainTextPassword <String> [-Header <String>] [-Footer <String>]
Invoke-ProtectedDatumAction -InputObject <String> -Certificate <String> [-Header <String>] [-Footer <String>]
```

> **Note**: This function is typically called automatically by the Datum framework. You do not need to invoke it directly unless testing.

## Examples

### Encrypt and Decrypt a Credential

```powershell
# Encrypt
$cred = Get-Credential
$password = ConvertTo-SecureString -String 'P@ssw0rd' -AsPlainText -Force
$encrypted = Protect-Datum -InputObject $cred -Password $password

# Decrypt
$decrypted = Unprotect-Datum -Base64Data $encrypted -Password $password
$decrypted.UserName  # Original username
$decrypted.GetNetworkCredential().Password  # Original password
```

### Encrypt a Secure String

```powershell
$secret = ConvertTo-SecureString -String 'SuperSecret' -AsPlainText -Force
$encrypted = Protect-Datum -InputObject $secret -Certificate 'Cert:\LocalMachine\My\THUMBPRINT'
```

### Check if Data is Encrypted

```powershell
Test-ProtectedDatumFilter -InputObject '[ENC=QUJD]'     # True
Test-ProtectedDatumFilter -InputObject 'plain text'      # False
```

## How It Works

1. **Encryption** (`Protect-Datum`):
   - Serializes the input object using `PSSerializer` (CLIXML format)
   - Encrypts using `Protect-Data` from the ProtectedData module
   - Serializes the encrypted blob again and converts to Base64
   - Wraps with `[ENC=` ... `]` header and footer

2. **Detection** (`Test-ProtectedDatumFilter`):
   - Checks if the value matches the `[ENC=...]` pattern via regex

3. **Decryption** (`Unprotect-Datum`):
   - Strips the `[ENC=` header and `]` footer
   - Decodes from Base64 and deserializes the CLIXML
   - Decrypts using `Unprotect-Data` from the ProtectedData module
   - Returns the original object in its original type

4. **Caching** (`Invoke-ProtectedDatumAction`):
   - Maintains a script-scoped cache of decrypted values
   - Returns cached results for previously decrypted data

## Real-World Usage with DSC Workshop

Datum.ProtectedData is designed to work within a layered
configuration data architecture such as the one provided by
the [DSC Workshop](https://github.com/dsccommunity/dscworkshop).
In a typical DSC Workshop setup, configuration data is
organized in layers from least-specific (environment-wide) to
most-specific (node-level). Encrypted secrets follow the same
layering and override model as any other configuration value.

### Credential Layering Example

A domain-wide credential can be defined in a base layer such
as `ServerBaseline.yml`:

```yaml
Domain:
  DomainFqdn: subdomain.environment01.com
  DomainName: subdomain
  DomainDN: DC=subdomain,DC=environment01,DC=com
  DomainJoinAccount: "[ENC=PE9ianMgVm...PC9PYmpzPg==]"
```

A role-specific override in `FileServer.yml` replaces only the
credential while inheriting the rest:

```yaml
Domain:
  DomainJoinAccount: "[ENC=PE9ianMgVm...T2Jqcz4=]"
```

During Datum resolution the most-specific value wins, so file
servers receive a different domain join account while all other
nodes use the baseline credential.

### MOF Encryption

When compiling DSC MOF files it is recommended to also encrypt
the MOF itself using a per-node document encryption
certificate. Assign each node a `CertificateID` in its LCM
settings so the Local Configuration Manager can decrypt the
MOF at apply time:

```yaml
LCMConfig:
  Settings:
    CertificateID: >-
      $((Get-ChildItem Cert:\LocalMachine\My
      -DnsName $Node.Name |
      Sort-Object NotBefore |
      Select-Object -First 1).Thumbprint)
```

This combines Datum.ProtectedData (encrypting configuration
data at rest in source control) with DSC's built-in MOF
encryption (encrypting credentials in the compiled MOF) for
end-to-end secret protection.

### Further Reading

- [DSC Configuration Data Encryption Done Right](https://www.janhendrikpeters.de/post/dsc-configuration-data-encryption-done-right/)
  — Jan-Hendrik Peters' walkthrough of layered credential
  encryption with Datum.ProtectedData
- [DSC Workshop](https://github.com/dsccommunity/dscworkshop)
  — Reference implementation of a layered DSC build pipeline
- [Securing MOF Files](https://learn.microsoft.com/en-us/powershell/scripting/dsc/pull-server/securemof)
  — Microsoft documentation on MOF encryption with
  certificates

## Contributing

Please check out the [Contributing Guide](CONTRIBUTING.md) for guidelines on how to contribute to this project.

## Change Log

A full list of changes in each version can be found in the [Change Log](CHANGELOG.md).
