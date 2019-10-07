function Remove-GitHubRepository {
    <#
    .Synopsis
    Deletes a GitHub repository, using the specified owner and repository name.

    .Notes
    Created by Trevor Sullivan <trevor@trevorsullivan.net>
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Owner,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[\w-\.]+$')]
        [Alias('Repository')]
        [string] $RepositoryName,

        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    $uri = 'repos/{0}/{1}' -f $Owner, $Name;
    Invoke-GitHubApi -Uri $uri -Method Delete -Token $Token;
}
