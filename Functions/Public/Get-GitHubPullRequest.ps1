function Get-GitHubPullRequest {
    <#
    .SYNOPSIS
    This cmdlet gets or lists pull request(s).

    .DESCRIPTION
    Gets or lists pull requests for given owner, repository and filter parameters.

    Available views: Table (table), Compact (custom), List (list), Full (list)

    .INPUTS
    PSGitHub.PullRequest. You can pipe the output of Get-GitHubPullRequest
    LibGit2Sharp.Repository. You can pipe the output of PowerGit's Get-GitRepository
    LibGit2Sharp.Branch. You can pipe the output of PowerGit's Get-GitBranch or Get-GitHead
    LibGit2Sharp.Commit. You can pipe the output of PowerGit's Get-GitCommit
    #>
    [CmdletBinding()]
    [OutputType('PSGitHub.PullRequest')]
    param(
        # The owner of the target repository
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Owner = (Get-GitHubUser -Token $Token).login, # This doesn't work for org repos.

        # The name of the target repository
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[\w-\.]+$')]
        [Alias('Repository')]
        [ValidateNotNullOrEmpty()]
        [string] $RepositoryName,

        # Number of the pull request
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Number')]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $Number,

        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('assigned', 'created', 'mentioned', 'subscribed', 'all')]
        [string] $Filter,

        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('open', 'closed', 'all')]
        [string] $State,

        [Parameter(ParameterSetName = 'List')]
        [string[]] $Labels,

        # Filter by head branch name.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'List')]
        [Alias('FriendlyName')] # For piping LibGit2Sharp.Branch
        [string] $HeadBranch,

        [Parameter(ParameterSetName = 'List')]
        [string] $ForkOwner,

        # Filter by base branch name.
        [Parameter(ParameterSetName = 'List')]
        [string] $BaseBranch,

        [Parameter(ParameterSetName = 'List')]
        [DateTime] $Since,

        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('created', 'updated', 'popularity', 'long-running')]
        [string] $Sort,

        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('asc', 'desc')]
        [string] $Direction,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    process {
        if (-not $ForkOwner) {
            $ForkOwner = $Owner
        }
        if ($HeadBranch) {
            $HeadBranch = "$($ForkOwner):$HeadBranch"
        }
        $url = "repos/$Owner/$RepositoryName/pulls"
        if ($Number) {
            $url += "/$Number"
        }
        $queryParams = @{
            state = $State
            sort = $Sort
            direction = $Direction
        }
        if ($HeadBranch) {
            $queryParams.head = $HeadBranch
        }
        if ($Labels) {
            $queryParams.labels = $Labels
        }
        if ($BaseBranch) {
            $queryParams.base = $BaseBranch
        }
        if ($Since) {
            $queryParams.since = $Since.ToString('o')
        }
        if ($Filter) {
            $queryParams.filter = $Filter
        }
        # expand arrays
        Invoke-GitHubApi $url -Body $queryParams -BaseUri $BaseUri -Token $Token -Accept 'application/vnd.github.shadow-cat-preview' | ForEach-Object { $_ } | ForEach-Object {
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
