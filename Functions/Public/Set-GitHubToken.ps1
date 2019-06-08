﻿function Set-GitHubToken {
    <#
    .Synopsis
    Internal function that obtains the username and Personal Access Token from the user.

    .Notes
    Created by Trevor Sullivan <trevor@trevorsullivan.net>
    #>
    [CmdletBinding()]
    [Obsolete('Use $PSDefaultParameterValues to set the -Token parameter for all PSGitHub functions')]
    param (
    )

    Write-Warning 'Set-GitHubToken is deprecated. Use $PSDefaultParameterValues to set the -Token parameter for all PSGitHub functions'

    ### Invoke the GitHub Personal Access Token screen
    Start-Process 'https://github.com/settings/tokens'

    ### TODO: Consider using Read-Host to support non-GUI scenarios
    $GitHubCredential = Get-Credential -Message 'Please enter your GitHub username and Personal Access Token. Visit https://github.com/settings/tokens to obtain a Personal Access Token.' -UserName '<GitHubUsername>';

    $TokenPath = '{0}\token.json' -f (Split-Path -Path $MyInvocation.MyCommand.Module.Path -Parent);

    @(@{
            Username = $GitHubCredential.UserName;
            PersonalAccessToken = $GitHubCredential.Password | ConvertFrom-SecureString;
    }) | ConvertTo-Json | Out-File -FilePath $TokenPath;
}
