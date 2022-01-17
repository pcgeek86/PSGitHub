function Update-GitHubPullRequest {
    <#
    .Synopsis
    Updates a GitHub pull request.

    .Parameter Title
    Required. The title of the new GitHub pull request that will be updated. This field doesn't support Markdown.

    .Parameter Body
    Optional. Defines the body text, using Markdown, for the GitHub pull request. Most people probably won't like you
    if you don't specify a body, so the recommendation would be to specify one.

    .Parameter Owner
    The GitHub username of the account or organization that owns the GitHub repository specified in the -RepositoryName parameter.

    .Parameter Repository
    Required. The name of the GitHub repository that is owned by the -Owner parameter, where the new GitHub pull request will be
    updated.

    .Parameter State
    Optional. The state to which the pull request will be set ('open' or 'closed').

    .Parameter Number
    The GitHub pull request number, in the specified GitHub repository, that will be updated.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType('PSGitHub.PullRequest', 'PSGitHub.Issue')]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('User')]
        [string] $Owner,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[\w-_\.]+$')]
        [Alias('Repository')]
        [string] $RepositoryName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [int] $Number,

        [string] $Title,
        [string] $Body,

        [ValidateSet('open', 'closed')]
        [string] $State,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('FriendlyName')] # PowerGit
        [string] $BaseBranch,

        [bool] $MaintainerCanModify,

        # Issue parameters

        # Team slugs whose members will be assigned (in addition to Assignees).
        # Previous assignees are replaced.
        [string[]] $TeamAssignees,

        # Usernames who will be assigned to the issue.
        # Previous assignees are replaced.
        [string[]] $Assignees,

        # An array of strings that indicate the labels that will replace the current list of labels of this GitHub issue. Optional.
        [string[]] $Labels,

        # The number of the milestone to associate this issue with or null to remove current. Optional.
        [AllowNull()]
        $MilestoneNumber,

        # The title of the milestone to associate this issue with or null to remove current. Optional.
        [AllowNull()]
        $MilestoneTitle,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token
    )

    process {
        $shouldProcessCaption = "Updating GitHub pull request"
        $shouldProcessDescription = "Updating GitHub pull request `e[1m#$Number`e[0m in repository `e[1m$Owner/$RepositoryName`e[0m."
        $shouldProcessWarning = "Do you want to update the GitHub pull request `e[1m#$Number`e[0m in repository `e[1m$Owner/$RepositoryName`e[0m?"

        if ($PSCmdlet.ShouldProcess($shouldProcessDescription, $shouldProcessWarning, $shouldProcessCaption)) {
            if ($TeamAssignees -or $Assignees -or $Labels -or $MilestoneNumber -or $MilestoneTitle) {
                $issueParams = @{
                    Owner = $Owner
                    RepositoryName = $RepositoryName
                    Number = $Number
                }
                if ($PSBoundParameters.ContainsKey('TeamAssignees')) {
                    $issueParams.TeamAssignees = $TeamAssignees
                }
                if ($PSBoundParameters.ContainsKey('Assignees')) {
                    $issueParams.Assignees = $Assignees
                }
                if ($PSBoundParameters.ContainsKey('Labels')) {
                    $issueParams.Labels = $Labels
                }
                if ($PSBoundParameters.ContainsKey('MilestoneNumber')) {
                    $issueParams.MilestoneNumber = $MilestoneNumber
                }
                if ($PSBoundParameters.ContainsKey('MilestoneTitle')) {
                    $issueParams.MilestoneTitle = $MilestoneTitle
                }
                Update-GitHubIssue @issueParams | Out-Null
            }

            $apiBody = @{ }
            if ($Title) {
                $apiBody.title = $Title
            }
            if ($Body) {
                $apiBody.body = $Body
            }
            if ($BaseBranch) {
                $apiBody.base = $BaseBranch
            }
            if ($PSBoundParameters.ContainsKey('MaintainerCanModify')) {
                $apiBody.maintainer_can_modify = [bool]$MaintainerCanModify
            }
            if ($State) {
                $apiBody.state = $State
            }
            $prApiParams = @{
                Body = $apiBody | ConvertTo-Json
                Uri = 'repos/{0}/{1}/pulls/{2}' -f $Owner, $RepositoryName, $Number;
                Method = 'Patch';
                Token = $Token
                BaseUri = $BaseUri
            }
            Invoke-GitHubApi @prApiParams | ForEach-Object {
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
}

