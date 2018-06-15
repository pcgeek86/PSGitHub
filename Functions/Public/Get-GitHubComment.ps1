function Get-GitHubComment {
    <#
    .SYNOPSIS
    Gets GitHub issue comments.

    .DESCRIPTION
    Gets a single comment, or all comments on an issue, or all comments in a
    repository, subject to filtering parameters.

    .PARAMETER Owner
    The GitHub username of the account or organization that owns the GitHub repository
    specified in the -Repository parameter.

    .PARAMETER Repository
    The name of the GitHub repository containing the issue.

    .PARAMETER All
    Retrieve all comments in the GitHub repository specified by the -Owner and
    -Repository parameters.

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
    Get-GitHubComment -Owner Mary -Repository WebApps -All

    .EXAMPLE
    # Retrieve all comments on Issue #42 in the repository Mary/WebApps:
    Get-GitHubComment -Owner Mary -Repository WebApps -Number 42

    .EXAMPLE
    # Retrieve all comments in the repository Mary/WebApps in 2017 or later.
    Get-GitHubComment -Owner Mary -Repository WebApps -Since 2017-01-01T00:00:00Z

    .EXAMPLE
    # Retrieve the comment with id 332551910 in the repository Mary/WebApps:
    Get-GitHubComment -Owner Mary -Repository WebApps -CommentId 332551910

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Alias('User')]
        [string] $Owner
        , [Parameter(Mandatory = $true)]
        [string] $Repository
        , [Parameter(Mandatory = $true, ParameterSetName = 'InRepo')]
        [switch] $All
        , [Parameter(Mandatory = $true, ParameterSetName = 'InIssue')]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $Number
        , [Parameter(Mandatory = $true, ParameterSetName = 'Single')]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $CommentId
        , [Parameter(Mandatory = $false, ParameterSetName = 'InRepo')]
        [Parameter(Mandatory = $false, ParameterSetName = 'InIssue')]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $Page
        , [Parameter(Mandatory = $false, ParameterSetName = 'InRepo')]
        [ValidateSet('created', 'updated')]
        [string] $Sort
        , [Parameter(Mandatory = $false, ParameterSetName = 'InRepo')]
        [ValidateSet('asc', 'desc')]
        [string] $Direction
        , [Parameter(Mandatory = $false, ParameterSetName = 'InRepo')]
        [Parameter(Mandatory = $false, ParameterSetName = 'InIssue')]
        [string] $Since
    )

    $restMethod = 'repos/{0}/{1}/issues' -f $Owner, $Repository
    if ($All) {
        $restMethod += '/comments'
    }
    elseif ($Number) {
        $restMethod += '/{0}/comments' -f $Number
    }
    elseif ($CommentId) {
        $restMethod += '/comments/{0}' -f $CommentId
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
        $restMethod += "?" + ($queryParameters -join '&')
    }

    $apiCall = @{
        Method     = 'Get';
        RestMethod = $restMethod
    }

    Invoke-GitHubApi @apiCall
}
