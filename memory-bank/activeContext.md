# Active Context

## Current Work Focus

**Sampler migration** of Datum.ProtectedData, using Datum.InvokeCommand as the
reference implementation.

## Analysis Complete - 2026-02-23

Both projects have been fully analyzed. Key findings:

### Datum.ProtectedData (Current State)

- Legacy build system: AppVeyor + InvokeBuild + PSDepend + PSDeploy
- Source lives in `Datum.ProtectedData/` folder (not `source/`)
- Public functions in `public/` subfolder (lowercase)
- No private functions
- 4 exported functions, all with comment-based help (decent quality)
- Tests use Pester v4 syntax, mostly placeholder assertions
- Module manifest uses wildcard exports
- Version hardcoded to `0.0.1`
- README is a single sentence
- No CHANGELOG, CONTRIBUTING, CODE_OF_CONDUCT, SECURITY files
- No GitVersion configuration
- No Azure Pipelines configuration
- Bug: typo in `Unprotect-Datum.ps1` - `'ByCertificae'` instead of `'ByCertificate'`

### Datum.InvokeCommand (Reference - Upgraded)

- Full Sampler scaffolding with `source/` layout
- Azure Pipelines with Build/Test/Deploy stages
- GitVersion for automated semver
- Pester 5 tests with `BeforeDiscovery`/`BeforeAll` blocks
- Complete `build.yaml` with all task definitions
- `RequiredModules.psd1` for dependency management
- Full community files (CHANGELOG, CONTRIBUTING, CODE_OF_CONDUCT, SECURITY)
- Comprehensive README with badges, examples, architecture
- `.vscode/` settings with PSSA analyzer configuration
- `.github/` issue and PR templates
- `.markdownlint.json` for markdown linting
- `codecov.yml` for coverage reporting
- `.gitattributes` for line ending normalization

## Next Steps

Execute the migration plan (see `progress.md` for detailed task tracking).

## Active Decisions

1. **No DscResource.Common dependency**: Unlike Datum.InvokeCommand, this module
   does not use localized strings or DscResource.Common. We will skip
   `Prefix.ps1`, `en-US/` strings, and `NestedModule` configuration unless
   needed.
2. **No NestedModule configuration**: This module has no nested module dependencies.
3. **Adapt, don't copy**: Build configuration will be adapted from the reference,
   not blindly copied. Items specific to Datum.InvokeCommand (WikiSource,
   DscResource.DocGenerator, DscResource.Test) will be omitted.
4. **Preserve module GUID**: Must keep `132c634a-1fe1-40f7-b327-5e723a0b23b2`.
5. **Starting version**: GitVersion `next-version` will be set to `0.2.0` to
   indicate the first post-migration release (the module was at `0.0.1`).

## Important Patterns

- Follow PowerShell instruction file standards (One True Brace Style, 4-space
  indent, camelCase locals, PascalCase scope vars)
- Follow changelog instruction file (Keep a Changelog format)
- Follow versioning instruction file (GitVersion + conventional commits)
- Follow YAML instruction file (2-space indent, consistent style)
