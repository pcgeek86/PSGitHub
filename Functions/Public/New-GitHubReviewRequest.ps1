function New-GitHubReviewRequest {
    <#
    .SYNOPSIS
        Requests review from one or more users for a pull request.
    .INPUTS
        PSGitHub.PullRequest
    #>
    [CmdletBinding()]
    [OutputType('PSGitHub.PullRequest')]
    param(
        # Number of the pull request
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $Number,

        # The owner of the target repository
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidatePattern('^[\w-\.]+$')] # safety check to make sure no owner/repo slug (with slash) was passed
        [string] $Owner = (Get-GitHubUser -Token $Token).login, # This doesn't work for org repos.

        # The name of the target repository
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[\w-\.]+$')]
        [Alias('Repository')]
        [string] $RepositoryName,

        # User logins that will be requested.
        [string[]] $Reviewers = @(),

        # Team slugs that will be requested.
        # The team must exist in the organization of the repository.
        [string[]] $TeamReviewers = @(),

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    process {
        $body = @{
            reviewers = $Reviewers
            team_reviewers = $TeamReviewers
        }

        Invoke-GithubApi -Method POST "repos/$Owner/$RepositoryName/pulls/$Number/requested_reviewers" `
            -Body ($body | ConvertTo-Json) `
            -BaseUri $BaseUri `
            -Token $Token |
            ForEach-Object {
                $_.PSTypeNames.Insert(0, 'PSGitHub.Issue') # every PR is an issue
                $_.PSTypeNames.Insert(0, 'PSGitHub.PullRequest')
                $_.User.PSTypeNames.Insert(0, 'PSGitHub.User')
                $_.Head.PSTypeNames.Insert(0, 'PSGitHub.Commit')
                $_.Base.PSTypeNames.Insert(0, 'PSGitHub.Commit')
                foreach ($label in $_.Labels) {
                    $label.PSTypeNames.Insert(0, 'PSGitHub.Label')
                }
                foreach ($assignee in $_.Assignees) {
                    $assignee.PSTypeNames.Insert(0, 'PSGitHub.User')
                }
                foreach ($reviewer in $_.RequestedReviewers) {
                    $reviewer.PSTypeNames.Insert(0, 'PSGitHub.User')
                }
                $_
            }
    }
}
