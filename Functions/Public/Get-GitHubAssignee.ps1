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
        [ValidatePattern('^[\w-]+$')]
        [Alias('Repository')]
        [string] $RepositoryName,

        [Security.SecureString] $Token
    )
    process {
        Invoke-GitHubApi "/repos/$Owner/$RepositoryName/assignees" -Token $Token | ForEach-Object { $_ } | ForEach-Object {
            $_.PSTypeNames.Insert(0, 'PSGitHub.User')
            $_
        }
    }
}
