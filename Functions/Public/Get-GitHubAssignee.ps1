function Get-GitHubAssignee {
    <#
    .SYNOPSIS
    This function returns a list of valid assignees for a GitHub repository.

    .INPUTS
    PSGitHub.PullRequest
    PSGitHub.Repository

    .LINK
    https://trevorsullivan.net
    https://developer.github.com/v3/issues/assignees/#list-assignees
    #>
    [CmdletBinding()]
    [OutputType('PSGitHub.User')]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Owner,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[\w-\.]+$')]
        [Alias('Repository')]
        [string] $RepositoryName,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token
    )
    process {
        Invoke-GitHubApi "repos/$Owner/$RepositoryName/assignees" -BaseUri $BaseUri -Token $Token | ForEach-Object { $_ } | ForEach-Object {
            $_.PSTypeNames.Insert(0, 'PSGitHub.User')
            $_
        }
    }
}
