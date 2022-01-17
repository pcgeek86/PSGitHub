function New-GitHubIssue {
    <#
    .Synopsis
    Creates a new GitHub issue.

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

    .Parameter Assignee
    Optional. The GitHub username of the individual who the new issues will be assigned to.

    .Parameter Labels
    Optional. An array of strings that indicate the labels that will be assigned to this GitHub issue upon creation.

    .Link
    https://trevorsullivan.net
    https://developer.github.com/v3/issues
    #>
    [CmdletBinding()]
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

        [Parameter(Mandatory)]
        [string] $Title,

        [string] $Body,
        [string[]] $Assignees,
        [string[]] $Labels,

        # The title of the milestone to associate this issue with. Optional.
        [AllowNull()]
        $MilestoneTitle,

        # The number of the milestone to associate this issue with. Optional.
        [AllowNull()]
        $MilestoneNumber,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    ### Build the core message body -- we'll add more properties soon
    $ApiBody = @{
        title = $Title;
    };

    ### Add an issue body to the message payload (optional)
    if ($Body) { $ApiBody.body = $Body }

    if ($Assignees) { $ApiBody.assignees = $Assignees }

    ### Add array of labels to the issue message body
    if ($Labels) { $ApiBody.labels = $Labels }

    ### Add the milestone to the issue message body
    if ($MilestoneName) {
        $MilestoneNumber = Get-GitHubMilestone | Where-Object { $_.Title -eq $MilestoneTitle } | ForEach-Object { $_.Number }
        if (-not $MilestoneNumber) {
            Write-Error "Milestone `"$($MilestoneTitle)`" does not exist"
            return
        }
    }
    if ($MilestoneNumber) { $ApiBody.milestone = $MilestoneNumber }

    ### Set up the API call
    $ApiCall = @{
        Body = $ApiBody | ConvertTo-Json
        Uri = 'repos/{0}/{1}/issues' -f $Owner, $RepositoryName;
        Method = 'Post';
        Token = $Token
        BaseUri = $BaseUri
    }

    ### Invoke the GitHub REST method
    Invoke-GitHubApi @ApiCall | ForEach-Object {
        $_.PSTypeNames.Insert(0, 'PSGitHub.Issue')
        $_.User.PSTypeNames.Insert(0, 'PSGitHub.User')
        foreach ($label in $_.Labels) {
            $label.PSTypeNames.Insert(0, 'PSGitHub.Label')
        }
        $_
    }
}
