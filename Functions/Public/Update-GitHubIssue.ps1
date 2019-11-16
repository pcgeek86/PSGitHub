function Update-GitHubIssue {
    <#
    .Synopsis
    Updates a GitHub issue.

    .Parameter Title
    Required. The title of the new GitHub issue that will be created. This field doesn't support Markdown.

    .Parameter Body
    Optional. Defines the body text, using Markdown, for the GitHub issue. Most people probably won't like you
    if you don't specify a body, so the recommendation would be to specify one.

    .Parameter Owner
    The GitHub username of the account or organization that owns the GitHub repository specified in the -RepositoryName parameter.

    .Parameter Repository
    Required. The name of the GitHub repository that is owned by the -Owner parameter, where the new GitHub issue will be
    created.

    .Parameter State
    Optional. The state to which the issue will be set ('open' or 'closed').

    .Parameter Number
    The GitHub issue number, in the specified GitHub repository, that will be updated.
    .Link
    https://trevorsullivan.net
    https://developer.github.com/v3/issues
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType('PSGitHub.Issue')]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('User')]
        [string] $Owner,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[\w-\.]+$')]
        [Alias('Repository')]
        [string] $RepositoryName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [int] $Number,

        [string] $Title,
        [string] $Body,

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

        [ValidateSet('open', 'closed')]
        [string] $State,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    process {
        $apiBody = @{ }
        if ($Title) {
            $apiBody.title = $Title
        }
        if ($Body) {
            $apiBody.body = $Body
        }
        if ($TeamAssignees) {
            $Assignees += $TeamAssignees |
                ForEach-Object { Get-GitHubTeam -OrganizationName $Owner -Slug $_ -Token $Token } |
                Get-GitHubTeamMember -Token $Token |
                ForEach-Object { $_.Login }
        }
        if ($Assignees) {
            $apiBody.assignees = $Assignees
        }
        if ($Labels) {
            $apiBody.labels = $Labels
        }
        if ($MilestoneTitle) {
            $MilestoneNumber = Get-GitHubMilestone -Owner $Owner -RepositoryName $RepositoryName |
                Where-Object { $_.Title -eq $MilestoneTitle } |
                ForEach-Object { $_.Number }
            if (-not $MilestoneNumber) {
                Write-Error "Milestone `"$($MilestoneTitle)`" does not exist"
                return
            }
        }
        if ($PSBoundParameters.ContainsKey('MilestoneNumber') -or $PSBoundParameters.ContainsKey('MilestoneTitle')) {
            $apiBody.milestone = $MilestoneNumber
        }
        if ($State) {
            $apiBody.state = $State
        }

        ### Set up the API call
        $ApiCall = @{
            Body = $apiBody | ConvertTo-Json
            Uri = 'repos/{0}/{1}/issues/{2}' -f $Owner, $RepositoryName, $Number;
            Method = 'Patch';
            Token = $Token
            BaseUri = $BaseUri
        }

        $shouldProcessCaption = "Updating GitHub issue"
        $shouldProcessDescription = "Updating GitHub issue `e[1m#$Number`e[0m in repository `e[1m$Owner/$RepositoryName`e[0m."
        $shouldProcessWarning = "Do you want to update the GitHub issue `e[1m#$Number`e[0m in repository `e[1m$Owner/$RepositoryName`e[0m?"

        if ($PSCmdlet.ShouldProcess($shouldProcessDescription, $shouldProcessWarning, $shouldProcessCaption)) {
            Invoke-GitHubApi @ApiCall | ForEach-Object {
                $_.PSTypeNames.Insert(0, 'PSGitHub.Issue')
                $_.User.PSTypeNames.Insert(0, 'PSGitHub.User')
                foreach ($label in $_.Labels) {
                    $label.PSTypeNames.Insert(0, 'PSGitHub.Label')
                }
                $_
            }
        }
    }
}

Export-ModuleMember -Alias (
    New-Alias -Name Set-GitHubIssue -Value Update-GitHubIssue -PassThru
)
