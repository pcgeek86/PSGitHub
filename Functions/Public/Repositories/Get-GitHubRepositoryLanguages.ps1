function Get-GitHubRepositoryLanguages {
    <#
    .Synopsis
    Retrieves the languages that make up the code in the GitHub repository.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Owner,
        [Parameter(Mandatory = $true)]
        [string] $RepositoryName
    )

    $Uri = 'repos/{0}/{1}/languages' -f $Owner, $RepositoryName
    Invoke-GitHubApi -Uri $Uri
}