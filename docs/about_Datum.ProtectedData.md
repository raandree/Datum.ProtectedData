# Datum.ProtectedData

## about_Datum.ProtectedData

# SHORT DESCRIPTION

Datum handler module to encrypt and decrypt secrets in Datum
configuration data using the ProtectedData module.

# LONG DESCRIPTION

Datum.ProtectedData is a handler module for the Datum
configuration management framework. It provides encryption
and decryption of sensitive data stored in YAML, JSON, or
PSD1 configuration files.

The module uses Dave Wyatt's ProtectedData module to perform
the actual encryption and decryption operations, supporting
both certificate-based and password-based scenarios.

When registered as a Datum handler, it automatically detects
encrypted data blocks (wrapped in `[ENC=...]`) and decrypts
them during configuration resolution.

## Exported Functions

- Protect-Datum: Encrypts an object into a base64 string
- Unprotect-Datum: Decrypts a base64 string to the object
- Test-ProtectedDatumFilter: Tests if data is encrypted
- Invoke-ProtectedDatumAction: Handler action for Datum

## Handler Registration

Register in your Datum.yml file:

```yaml
DatumHandlers:
  Datum.ProtectedData::ProtectedDatum:
    CommandOptions:
      Certificate: <thumbprint>
```

# EXAMPLES

```powershell
# Encrypt a credential
$cred = Get-Credential
$pass = ConvertTo-SecureString 'P@ssw0rd' -AsPlainText -Force
Protect-Datum -InputObject $cred -Password $pass

# Test if data is encrypted
Test-ProtectedDatumFilter -InputObject '[ENC=QUJD]'

# Decrypt data
$decrypted = Unprotect-Datum -Base64Data $encrypted `
    -Password $pass
```

# NOTE

The PlainTextPassword parameter in Invoke-ProtectedDatumAction
and the Password parameter in Protect-Datum/Unprotect-Datum
are intended for testing and development only. In production,
always use certificate-based encryption.

# SEE ALSO

- Datum: https://github.com/gaelcolas/datum/
- ProtectedData: https://github.com/dlwyatt/ProtectedData
- DSC Workshop: https://github.com/dsccommunity/dscworkshop
- DSC Configuration Data Encryption Done Right (Jan-Hendrik
  Peters): https://www.janhendrikpeters.de/post/dsc-configuration-data-encryption-done-right/
- Securing MOF Files: https://learn.microsoft.com/en-us/powershell/scripting/dsc/pull-server/securemof

# KEYWORDS

- Datum
- ProtectedData
- Encryption
- Decryption
- Secrets
- Configuration
- DSC
