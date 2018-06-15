function Get-GitHubToken {
    <#
    .Synopsis
    Internal function to retrieve the GitHub Personal Access Token from disk

    .Notes
    Created by Trevor Sullivan <trevor@trevorsullivan.net>
    #>
    [OutputType([System.Management.Automation.PSCredential])]
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
    param (
    )

    ### Detect if we are running inside the Microsoft Azure Automation service
    if (!(Get-Command -Name Get-AutomationPSCredential -ErrorAction Ignore) -or (Get-Process -Name System)) {
        ### Read the token from disk
        $Token = Get-Content -Path ('{0}\token.json' -f (Split-Path -Path $MyInvocation.MyCommand.Module.Path -Parent)) -Raw | ConvertFrom-Json;

        ### Combine the username and password, per GitHub developer documentation for Basic Authentication Scheme
        ### https://developer.github.com/v3/auth/
        $PersonalAccessToken = New-Object -TypeName PSCredential -ArgumentList @($Token.Username, ($Token.PersonalAccessToken | ConvertTo-SecureString));
        $UserPass = '{0}:{1}' -f $PersonalAccessToken.Username, $PersonalAccessToken.GetNetworkCredential().Password;
    }
    else {
        ### If we're running inside Azure Automation, then retrieve the credential from the Asset Store
        $GitHubCredential = Get-AutomationPSCredential -Name GitHub;
        $UserPass = '{0}:{1}' -f $GitHubCredential.UserName, $GitHubCredential.GetNetworkCredential().Password;
    }

    ### Convert the username and password to a Base64 string (RFC 1945 / HTTP/1.0)
    $Base64Token = [System.Convert]::ToBase64String([char[]]$UserPass) | ConvertTo-SecureString -AsPlainText -Force;

    ### Return the Base64 encoded credential as a PSCredential to minimize risk of disclosure
    ### NOTE: The username of this PSCredential instance is irrelevant, as the username / password combination
    ####      have already been encoded as Base64 above.
    return New-Object -TypeName PSCredential -ArgumentList @('GitHub', $Base64Token);
}
