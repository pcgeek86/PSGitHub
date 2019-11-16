function Get-GitHubMilestone {
    <#
    .Synopsis
    Creates a new GitHub issue.

    .Parameter Owner
    The GitHub username of the account or organization that owns the GitHub repository specified in the -RepositoryName parameter.

    .Parameter Repository
    Required. The name of the GitHub repository that is owned by the -Owner parameter, where the new GitHub issue will be
    created.

    .Parameter Milestone
    The number of the milestone that you want to retrieve.

    .Example
    ### Get a specific milestone, based on the milestone's number.
    Get-GitHubMilestone -Milestone 1;

    .Example
    ### Get a list of milestone for the specified repository
    Get-GitHubMilestone -Owner pcgeek86 -RepositoryName PSGitHub;

    .Link
    https://trevorsullivan.net
    https://developer.github.com/v3/issues
    #>
    [CmdletBinding()]
    [OutputType('PSGitHub.Milestone')]
    param (
        [Parameter(Mandatory)]
        [Alias('User')]
        [string] $Owner,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[\w-\.]+$')]
        [Alias('Repository')]
        [string] $RepositoryName,

        [Parameter(ParameterSetName = 'SpecificMilestone', Mandatory)]
        [int] $Number,

        [Parameter(ParameterSetName = 'FindMilestones')]
        [ValidateSet('Open', 'Closed', 'All')]
        [string] $State,

        [Parameter(ParameterSetName = 'FindMilestones')]
        [ValidateSet('DueDate', 'Completeness')]
        [string] $Sort,

        [Parameter(ParameterSetName = 'FindMilestones')]
        [ValidateSet('Ascending', 'Descending')]
        [string] $Direction,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    $queryParams = @{ };
    if ($Sort) {
        $queryParams.sort = ($Sort -creplace '([a-z])([A-Z])', '$1_$2').ToLower(); # PascalCase to snake_case
    }
    if ($State) {
        $queryParams.state = $State.ToLower();
    }
    if ($Direction) {
        $queryParams.direction = ($Direction -replace 'ending$', '').ToLower();
    }
    $Uri = if ($Number) {
        'repos/{0}/{1}/milestones/{2}' -f $Owner, $RepositoryName, $Number;
    } else {
        'repos/{0}/{1}/milestones' -f $Owner, $RepositoryName;
    }

    Invoke-GitHubApi -Method GET $Uri -Body $queryParams -BaseUri $BaseUri -Token $Token | ForEach-Object { $_ } | ForEach-Object {
        $_.PSTypeNames.Insert(0, 'PSGitHub.Milestone')
        $_.Creator.PSTypeNames.Insert(0, 'PSGitHub.User')
        $_
    }
}
