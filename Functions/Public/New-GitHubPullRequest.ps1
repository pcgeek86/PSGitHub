function New-GitHubPullRequest {
    <#
    .SYNOPSIS
        This cmdlet creates submitts a pull request to a repo

    .DESCRIPTION
        This cmdlet submitts a pull request from branch to an upstream branch,
        you can set the title and body of the pull request (default),
        alternatively you can also creates a pull request based on issue.

    .PARAMETER Owner
        Optional.
        the Owner of the upstream repo (the repo that you want to send the pull request to),
        default is the user returned by Get-GitHubAuthenticatedUser

    .PARAMETER Repository
        Mandatory.
        the name of the upstream repo (the repo that you want to send the pull request to)

    .PARAMETER Head
        Mandatory. The name of the branch where your changes are implemented.
        For cross-RepositoryName pull requests in the same network, namespace head with a user like this: username:branch

    .PARAMETER Base
        The name of the branch you want the changes pulled into. This should be an existing branch on the current repository.
        You cannot submit a pull request to one repository that requests a merge to a base of another repository.
        Defaults to default branch of the repository.

    .PARAMETER Title
        Mandatory if you want to send the pull request via title and body
        The title of the pull request.

    .PARAMETER Body
        Optional. The contents of the pull request.

    .PARAMETER Issue
        Mandatory if you want to send the pull request via existing issue.
        The issue number in this repository to turn into a Pull Request.

    .EXAMPLE
        # creates a pull request from my 'master' (chantisnake is my user name) to upstream 'master'
        C:\PS> New-GitHubPullRequest -Owner  'test-orgnization' -RepositoryName 'test-repo' -Head 'chantisnake:master' -Base master -Title 'new test pull request' -body 'the awesome content in the pull request'

        # creates a pull request via issue #2
        New-GitHubPullRequest -Owner  'test-orgnization' -RepositoryName 'test-repo' -Head 'chantisnake:master' -Base master -issue 2

    .NOTES
        Please make sure the Head is in the right format.

    #>
    [CmdletBinding(DefaultParameterSetName = 'title')]
    [OutputType('PSGitHub.PullRequest')]
    param(
        # The owner of the target repository
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidatePattern('^[\w-]+$')] # safety check to make sure no owner/repo slug (with slash) was passed
        [string] $Owner = (Get-GitHubUser -Token $Token).login, # This doesn't work for org repos.

        # The name of the target repository
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[\w-]+$')]
        [Alias('Repository')]
        [string] $RepositoryName,

        # The owner of the fork, if the pull request shall not be created from a branch in the same repository.
        # This is needed for pull requests from forks.
        # If set, Head will be prefixed with this owner followed by a colon.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $ForkOwner,

        # The head branch name
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('FriendlyName')] # Support piping LibGit2Sharp.Branch object
        [string] $Head,

        # The base branch name.
        # Defaults to the default branch of the target repository.
        [string] $Base,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'title')]
        [string] $Title,

        [Parameter(ParameterSetName = 'title')]
        [string] $Body,

        [string[]] $Labels,

        # The number of the milestone to associate this pull request with.
        $MilestoneNumber,

        # The title of the milestone to associate this pull request with.
        $MilestoneTitle,

        [string[]] $Assignees,

        # Team slugs whose members will be assigned.
        [string[]] $TeamAssignees,

        # User logins that will be requested for review.
        [string[]] $Reviewers,

        # Team slugs whose members will be requested for review.
        # The team must exist in the organization of the repository.
        [string[]] $TeamReviewers,

        # The ID of the project column this pull request should be added too.
        [int] $ProjectColumnId,

        [switch] $Draft,

        [Parameter(Mandatory, ParameterSetName = 'issue')]
        [int] $Issue,

        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    process {
        if (-not $Base) {
            $Base = (Get-GitHubRepository -Owner $Owner -RepositoryName $RepositoryName -Token $Token).default_branch
            if (-not $Base) {
                return
            }
        }
        if ($ForkOwner) {
            $Head = $ForkOwner + ":" + $Head
        }
        $apiBody = @{
            head = $Head
            base = $Base
            draft = [bool]$Draft
        }
        if ($PSCmdlet.ParameterSetName -eq 'title') {
            # send the pull request via title and body
            $apiBody['title'] = $Title
            $apiBody['body'] = $Body
        } else {
            # send the pull request via existing issue
            $apiBody['issue'] = $Issue
        }
        $headers = @{
            Accept = 'application/vnd.github.shadow-cat-preview'
        }

        $pr = Invoke-GithubApi "repos/$Owner/$RepositoryName/pulls" `
            -Method POST `
            -Body ($apiBody | ConvertTo-Json) `
            -Token $Token `
            -Headers $headers

        # Add TypeNames
        $pr.PSTypeNames.Insert(0, 'PSGitHub.PullRequest')
        $pr.PSTypeNames.Insert(0, 'PSGitHub.Issue') # every PR is an issue
        $pr.PSTypeNames.Insert(0, 'PSGitHub.PullRequest')
        $pr.User.PSTypeNames.Insert(0, 'PSGitHub.User')
        $pr.Head.PSTypeNames.Insert(0, 'PSGitHub.Commit')
        $pr.Base.PSTypeNames.Insert(0, 'PSGitHub.Commit')
        foreach ($label in $pr.Labels) {
            $label.PSTypeNames.Insert(0, 'PSGitHub.Label')
        }
        foreach ($assignee in $pr.Assignees) {
            $assignee.PSTypeNames.Insert(0, 'PSGitHub.User')
        }
        foreach ($reviewer in $pr.RequestedReviewers) {
            $reviewer.PSTypeNames.Insert(0, 'PSGitHub.User')
        }

        if ($Labels -or $TeamAssignees -or $Assignees -or $MilestoneTitle -or $MilestoneNumber) {
            # Update PR with issue properties
            $pr = $pr | Update-GitHubIssue `
                -TeamAssignees $TeamAssignees `
                -Assignees $Assignees `
                -MilestoneNumber $MilestoneNumber `
                -MilestoneTitle $MilestoneTitle `
                -Labels $Labels `
                -Token $Token |
                # Update PR object
                Get-GitHubPullRequest -Token $Token
        }

        if ($Reviewers -or $TeamReviewers) {
            $pr = $pr | New-GitHubReviewRequest -Reviewers $Reviewers -TeamReviewers $TeamReviewers -Token $Token
        }
        if ($ProjectColumnId) {
            New-GitHubProjectCard -ColumnId $ProjectColumnId -ContentType PullRequest -ContentId $pr.Id -Token $Token
        }

        $pr
    }
}
