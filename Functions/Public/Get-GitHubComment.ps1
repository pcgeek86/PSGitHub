function Get-GitHubComment {
    <#
    .SYNOPSIS
    Gets GitHub issue or pull request comments.

    .DESCRIPTION
    Gets a single comment, or all comments on an issue, or all comments in a
    repository, subject to filtering parameters.

    .PARAMETER Owner
    The GitHub username of the account or organization that owns the GitHub repository
    specified in the -RepositoryName parameter.

    .PARAMETER Repository
    The name of the GitHub repository containing the issue.

    .PARAMETER All
    Retrieve all comments in the GitHub repository specified by the -Owner and
    -RepositoryName parameters.

    .PARAMETER Number
    The number of the issue to retrieve.

    .PARAMETER CommentId
    The id of the comment to retrieve.

    .PARAMETER Page
    The page number of the results to return. Default: 1
    Note: The GitHub documentation of pagination warns to always rely on the
    links provided in the response headers, rather than attempting to construct
    the page URLs by hand. Unfortunately, as of PowerShell 5.1, Invoke-RestApi
    does not provide access to the response headers.
    https://developer.github.com/v3/guides/traversing-with-pagination/

    .PARAMETER Sort
    What to sort results by. Valid values: created, updated.
    Default: created.

    .PARAMETER Direction
    The direction to sort. Valid values: asc, desc. Default: desc

    .PARAMETER Since
    Limit the results to issues updated at or after the specified time. The time
    is specified in ISO 8601 format: YYYY-MM-DDTHH:MM:SSZ

    .EXAMPLE
    # Retrieve all comments in the repository Mary/WebApps:
    Get-GitHubComment -Owner Mary -RepositoryName WebApps -All

    .EXAMPLE
    # Retrieve all comments on Issue #42 in the repository Mary/WebApps:
    Get-GitHubComment -Owner Mary -RepositoryName WebApps -Number 42

    .EXAMPLE
    # Retrieve all comments in the repository Mary/WebApps in 2017 or later.
    Get-GitHubComment -Owner Mary -RepositoryName WebApps -Since 2017-01-01T00:00:00Z

    .EXAMPLE
    # Retrieve the comment with id 332551910 in the repository Mary/WebApps:
    Get-GitHubComment -Owner Mary -RepositoryName WebApps -CommentId 332551910

    #>
    [CmdletBinding()]
    [OutputType('PSGitHub.Comment')]
    param (
        [Parameter(Mandatory)]
        [Alias('User')]
        [string] $Owner,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[\w-\.]+$')]
        [Alias('Repository')]
        [string] $RepositoryName,

        [Parameter(Mandatory, ParameterSetName = 'InRepo')]
        [switch] $All,

        # The issue or pull request number. Supports piping an issue or pull request.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'InIssue')]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $Number,

        [Parameter(Mandatory, ParameterSetName = 'Single')]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $CommentId,

        [Parameter(ParameterSetName = 'InRepo')]
        [Parameter(ParameterSetName = 'InIssue')]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $Page,

        [Parameter(ParameterSetName = 'InRepo')]
        [ValidateSet('created', 'updated')]
        [string] $Sort,

        [Parameter(ParameterSetName = 'InRepo')]
        [ValidateSet('asc', 'desc')]
        [string] $Direction,

        [Parameter(ParameterSetName = 'InRepo')]
        [Parameter(ParameterSetName = 'InIssue')]
        [string] $Since,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    $uri = "repos/$Owner/$RepositoryName/issues"
    if ($All) {
        $uri += "/comments"
    } elseif ($Number) {
        $uri += "/$Number/comments"
    } elseif ($CommentId) {
        $uri += "/comments/$CommentId"
    }

    $queryParameters = @()
    if ($Page) {
        $queryParameters += "page=$Page"
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
        $_.PSTypeNames.Insert(0, 'PSGitHub.Comment')
        $_.User.PSTypeNames.Insert(0, 'PSGitHub.User')
        $_
    }
}
