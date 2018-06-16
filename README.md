[![Join the chat at https://gitter.im/pcgeek86/PSGitHub](https://badges.gitter.im/pcgeek86/PSGitHub.svg)](https://gitter.im/pcgeek86/PSGitHub?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/PSGitHub.svg)]()
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/PSGitHub.svg)]()

# What is PSGitHub?

The PSGitHub PowerShell module contains commands to manage GitHub through its REST API.

# Installation

You can install the PSGitHub PowerShell module using one of the following methods.

1. Install from the PowerShell Gallery (requires PowerShell 5.0+)
   ```powershell
   Install-Module PSGitHub
   ```
2. Copy-install the module to your `$env:PSModulePath`
3. Extract the module anywhere on the filesystem, and import it explicitly, using `Import-Module`

# Setup

To access private repositories, make changes and have a higher rate limit, [create a GitHub token](https://github.com/settings/tokens/new).
This token can be provided to all PSGitHub functions as a `SecureString` through the `-Token` parameter.
You can set a default token to be used by changing `$PSDefaultParameterValues` in your `profile.ps1`:

### On Windows
```powershell
$PSDefaultParameterValues['*GitHub*:Token'] = 'YOUR_ENCRYPTED_TOKEN' | ConvertTo-SecureString
```

To get the value for `YOUR_ENCRYPTED_TOKEN`, run `Read-Host -AsSecureString | ConvertFrom-SecureString` once and paste in your token.

### On macOS/Linux

macOS and Linux do not have access to the Windows Data Protection API, so they cannot use `ConvertFrom-SecureString`
to generate an encrypted plaintext version of the token without a custom encryption key.

If you are not concerned about storing the token in plain text in the `profile.ps1`, you can set it like this:

```powershell
$PSDefaultParameterValues['*GitHub*:Token'] = 'YOUR_PLAINTEXT_TOKEN' | ConvertTo-SecureString -AsPlainText -Force
```

Alternatively, you could store the token in a password manager or the Keychain, then retrieve it in your profile and set it the same way.

# Issues

Please report issues in the GitHub Issue Tracker.

# Contributors

This module was originally developed by Trevor Sullivan. You can contact Trevor using one of the following methods:

- E-mail: trevor@trevorsullivan.net
- Website: https://trevorsullivan.net
- Twitter: https://twitter.com/pcgeek86
- GitHub: https://github.com/pcgeek86

## Core Contributors

- Thomas Malkewitz
  - Skype: thomasmalkewitz
  - Twitter: @dotps1
  - Website: https://dotps1.github.io
