function Get-GitHubIssue {
    <#
    .SYNOPSIS
    Gets GitHub issues.

    .DESCRIPTION
    This command retrieves GitHub issues either for the authenticated user or from
    a specified repository.

    .PARAMETER All
    Retrieve "all issues assigned to the authenticated user across all visible
    repositories including owned repositories, member repositories, and organization
    repositories" (https://developer.github.com/v3/issues/).

    .PARAMETER ForUser
    Retrieve issues assigned to the authenticated user in those repos owned by
    the authenticated user, or of which the authenticated user is a member.

    .PARAMETER Organization
    Retrieve issues assigned to the authenticated user in repos belonging to the
    specified organization.

    .PARAMETER Owner
    The GitHub username of the account or organization that owns the GitHub repository
    specified in the -RepositoryName parameter.

    .PARAMETER Repository
    Retrieve all open issues from the GitHub repository with the specified name,
    owned by the GitHub user specified by -Owner.

    .PARAMETER Number
    Retrieve the single issue with the specified number from the repo specified
    by -Owner and -RepositoryName.

    .PARAMETER Page
    The page number of the results to return. Default: 1
    Note: The GitHub documentation of pagination warns to always rely on the
    links provided in the response headers, rather than attempting to construct
    the page URLs by hand. Unfortunately, as of PowerShell 5.1, Invoke-RestApi
    does not provide access to the response headers.
    https://developer.github.com/v3/guides/traversing-with-pagination/

    .PARAMETER Filter
    Indicates which sorts of issues to return. Valid values:
    * assigned: Issues assigned to the authenticated user.
    * created: Issues created by the authenticated user.
    * mentioned: Issues mentioning the authenticated user.
    * subscribed: Issues for which the authenticated user has subscribed to updates.
    * all: All issues the authenticated user can see, regardless of participation or creation.
    Default: assigned

    .PARAMETER State
    Limit the results to issues with the specified state. Valid values: open,
    closed, all. Default: open.

    .PARAMETER Labels
    Limit the results to issues with all of of the specified, comma-separated
    list of labels.

    .PARAMETER Sort
    What to sort results by. Valid values: created, updated, comments.
    Default: created.

    .PARAMETER Direction
    The direction to sort. Valid values: asc, desc. Default: desc

    .PARAMETER Since
    Limit the results to issues updated at or after the specified time. The time
    is specified in ISO 8601 format: YYYY-MM-DDTHH:MM:SSZ

    .EXAMPLE
    # Retrieve all open issues for the authenticated user, including issues from
    # owned, member, and organization repositories:
    Get-GitHubIssue -All

    .EXAMPLE
    # Retrieve open issues for the authenticated user, including only issues from
    # owned and member repositories.
    Get-GitHubIssue -ForUser

    .EXAMPLE
    # Retrieve open issues assigned to the authenticated user in repos owned by
    # the organization ExampleOrg:
    Get-GitHubIssue -Organization ExampleOrg

    .EXAMPLE
    # Retrieve all open issues in the repository Mary/WebApps:
    Get-GitHubIssue -Owner Mary -RepositoryName WebApps

    .EXAMPLE
    # Retrieve all issues (both open and closed) in the repository Mary/WebApps:
    Get-GitHubIssue -Owner Mary -RepositoryName WebApps -State all

    #>
    [CmdletBinding()]
    [OutputType('PSGitHub.Issue')]
    param (

        [Parameter(Mandatory, ParameterSetName = 'All')]
        [switch] $All,

        [Parameter(Mandatory, ParameterSetName = 'ForUser')]
        [switch] $ForUser,

        [Parameter(Mandatory, ParameterSetName = 'Organization')]
        [string] $Organization,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Repository')]
        [Alias('User')]
        [string] $Owner,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Repository')]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[\w-_\.]+$')]
        [Alias('Repository')]
        [string] $RepositoryName,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Repository')]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $Number,

        [ValidateRange(1, [int]::MaxValue)]
        [int] $Page,

        [ValidateSet('assigned', 'created', 'mentioned', 'subscribed', 'all')]
        [string] $Filter,

        [ValidateSet('open', 'closed', 'all')]
        [string] $State,

        [string[]] $Labels,

        [ValidateSet('created', 'updated', 'comments')]
        [string] $Sort,

        [ValidateSet('asc', 'desc')]
        [string] $Direction,

        [string] $Since,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    process {

        if ($RepositoryName) {
            $uri = 'repos/{0}/{1}/issues' -f $Owner, $RepositoryName
            if ($Number -gt 0) {
                $uri += ("/{0}" -f $Number)
            }
        } elseif ($Organization) {
            $uri = 'orgs/{0}/issues' -f $Organization
        } elseif ($ForUser) {
            $uri = 'user/issues'
        } else {
            $uri = 'issues'
        }

        $queryParameters = @()
        if ($Page) {
            $queryParameters += "page=$Page"
        }

        if ($Filter) {
            $queryParameters += "filter=$Filter"
        }

        if ($State) {
            $queryParameters += "state=$State"
        }

        if ($Labels) {
            $queryParameters += "labels=" + ($Labels -join ',')
        }

        if ($Sort) {
            $queryParameters += "sort=$Sort"
        }

        if ($Direction) {
            $queryParameters += "direction=$Direction"
        }

        if ($Since) {
            $queryParameters += "since=$Since"
        }

        if ($queryParameters) {
            $uri += "?" + ($queryParameters -join '&')
        }

        $apiCall = @{
            Method = 'Get';
            Uri = $uri
            Token = $Token
            BaseUri = $BaseUri
        }

        Invoke-GitHubApi @apiCall | ForEach-Object { $_ } | ForEach-Object {
            $_.PSTypeNames.Insert(0, 'PSGitHub.Issue')
            if ($null -ne $_.PSObject.Properties['pull_request']) {
                $_.PSTypeNames.Insert(0, 'PSGitHub.PullRequest')
            }
            $_.User.PSTypeNames.Insert(0, 'PSGitHub.User')
            foreach ($label in $_.Labels) {
                $label.PSTypeNames.Insert(0, 'PSGitHub.Label')
            }
            Write-Verbose "Received issue $($_.Title)"
            $_
        }
    }
}
