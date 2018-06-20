
function Get-GitHubToken {
    <#
    .Synopsis
    OBSOLETE Internal function to retrieve the GitHub Personal Access Token from disk.

    .Notes
    Created by Trevor Sullivan <trevor@trevorsullivan.net>
    #>
    [CmdletBinding()]
    [OutputType([Security.SecureString])]
    [Obsolete('Tokens should be provided through the -Token parameter or $PSDefaultParameterValues')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
    param (
    )

    # Linux and macOS do not have Windows Data Protection API,
    # so they cannot store a token encrypted in a config file
    if ($IsMacOS -or $IsLinux) {
        return
    }

    $tokenPath = '{0}\token.json' -f (Split-Path -Path $MyInvocation.MyCommand.Module.Path -Parent)

    ### Detect if we are running inside the Microsoft Azure Automation service
    if (!(Get-Command -Name Get-AutomationPSCredential -ErrorAction Ignore) -or (Get-Process -Name System)) {
        # Read the token from disk
        if (!(Test-Path $tokenPath)) {
            return
        }
        $config = (Get-Content -Path $tokenPath -Raw | ConvertFrom-Json)
        if ([string]::IsNullOrEmpty($config.PersonalAccessToken)) {
            return
        }
        Write-Warning 'Relying on a token set through Set-GitHubToken is deprecated. Provide the -Token parameter or set it through $PSDefaultParameterValues'
        $config.PersonalAccessToken | ConvertTo-SecureString
    }
    else {
        ### If we're running inside Azure Automation, then retrieve the credential from the Asset Store
        $gitHubCredential = Get-AutomationPSCredential -Name GitHub;
        $gitHubCredential.Password
    }
}
