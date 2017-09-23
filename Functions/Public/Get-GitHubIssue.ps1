function Get-GitHubIssue {
    <#
    .SYNOPSIS
    Gets GitHub issues.

    .DESCRIPTION
    This command retrieves GitHub issues either for the authenticated user or from 
    a specified repository.

    .Parameter All
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
    specified in the -Repository parameter.

    .PARAMETER Repository
    Retrieve all open issues from the GitHub repository with the specified name,
    owned by the GitHub user specified by -Owner.

    .PARAMETER State
    Limit the results to issues with the specified state. Valid values: open,
    closed, all. If not specified, the REST API returns only open issues.

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
    Get-GitHubIssue -Owner Mary -Repository WebApps

    .EXAMPLE
    # Retrieve all issues (both open and closed) in the repository Mary/WebApps:
    Get-GitHubIssue -Owner Mary -Repository WebApps -State all

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'All')]
        [switch] $All
      , [Parameter(Mandatory = $true, ParameterSetName = 'ForUser')]
        [switch] $ForUser
      , [Parameter(Mandatory = $true, ParameterSetName = 'Organization')]
        [string] $Organization
      , [Parameter(Mandatory = $true, ParameterSetName = 'Repository')]
        [Alias('User')]
        [string] $Owner
      , [Parameter(Mandatory = $true, ParameterSetName = 'Repository')]
        [string] $Repository
      , [Parameter()]
        [ValidateSet('open', 'closed', 'all')]
        [string] $State
    )

    if ($Repository) {
        $RestMethod = 'repos/{0}/{1}/issues' -f $Owner, $Repository
    } elseif ($Organization) {
        $RestMethod = 'orgs/{0}/issues' -f $Organization
    } elseif ($ForUser) {
        $RestMethod = 'user/issues'
    } else {
        $RestMethod = 'issues'
    }

    $queryParameters = @()
    if ($State) {
        $queryParameters += "state=$State"
    }

    if ($queryParameters) {
        $RestMethod += "?" + $queryParameters -join "&"
    }

    $apiCall = @{
        Method = 'Get';
        RestMethod = $RestMethod
    }

    Invoke-GitHubApi @apiCall
}