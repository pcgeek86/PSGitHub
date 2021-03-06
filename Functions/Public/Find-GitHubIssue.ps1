﻿function Find-GitHubIssue {
    <#
    .SYNOPSIS
        Searches GitHub issues and pull requests by a search query.
    #>
    [CmdletBinding()]
    [OutputType('PSGitHub.Issue')]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string] $Query,

        [ValidateSet('stars', 'forks', 'help-wanted-issues', 'updated')]
        [string] $Sort,

        [ValidateSet('asc', 'desc')]
        [Alias('Direction')]
        [string] $Order,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    process {
        $params = @{
            q = $Query
            sort = $Sort
            order = $Order
        }
        Invoke-GitHubApi 'search/issues' -Body $params -BaseUri $BaseUri -Token $Token |
            ForEach-Object { $_.items } |
            ForEach-Object {
                $_.PSTypeNames.Insert(0, 'PSGitHub.Issue')
                if ($null -ne $_.PSObject.Properties['pull_request']) {
                    $_.PSTypeNames.Insert(0, 'PSGitHub.PullRequest')
                }
                foreach ($label in $_.Labels) {
                    $label.PSTypeNames.Insert(0, 'PSGitHub.Label')
                }
                $_
            }
    }
}

Export-ModuleMember -Alias @(
    (New-Alias -Name Search-GitHubIssues -Value Find-GitHubIssue -PassThru),
    (New-Alias -Name Find-GitHubPullRequest -Value Find-GitHubIssue -PassThru),
    (New-Alias -Name Search-GitHubPullRequests -Value Find-GitHubIssue -PassThru)
)
