function Remove-GitHubRepository {
    <#
    .Synopsis
    Deletes a GitHub repository, using the specified owner and repository name.

    .Notes
    Created by Trevor Sullivan <trevor@trevorsullivan.net>
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Owner,
        [Parameter(Mandatory = $true)]
        [string] $Name,
        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    $Method = 'repos/{0}/{1}' -f $Owner, $Name;
    Invoke-GitHubApi -Uri $Method -Method Delete -Token $Token;
}
