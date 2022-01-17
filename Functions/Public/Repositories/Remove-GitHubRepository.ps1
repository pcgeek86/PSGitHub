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
        [Alias('Repository', 'Name')]
        [string] $RepositoryName,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token
    )

    $uri = 'repos/{0}/{1}' -f $Owner, $Name;
    Invoke-GitHubApi -Uri $uri -Method Delete -BaseUri $BaseUri -Token $Token;
}
