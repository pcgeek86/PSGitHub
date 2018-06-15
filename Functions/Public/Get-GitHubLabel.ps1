function Get-GitHubLabel {
    <#
    .SYNOPSIS
    Gets GitHub labels.

    .DESCRIPTION
    This command retrieves GitHub labels for the specified repository using
    the authenticated user.

    .PARAMETER Owner
    The GitHub username of the account or organization that owns the GitHub
    repository specified in the parameter -Repository parameter.

    .PARAMETER Repository
    The name of the GitHub repository, that is owned by the GitHub username
    specified by parameter -Owner.

    .PARAMETER Name
    Retrieve a single label with the specified name from the GitHub repository
    specified by the parameters -Owner and -Repository.

    .PARAMETER Page
    The page number of the results to return. Default: 1
    Note: The GitHub documentation of pagination warns to always rely on the
    links provided in the response headers, rather than attempting to construct
    the page URLs by hand. Unfortunately, as of PowerShell 5.1, Invoke-RestApi
    does not provide access to the response headers.
    https://developer.github.com/v3/guides/traversing-with-pagination/

    .EXAMPLE
    # Retrieve all labels from the repository Mary/WebApps:
    Get-GitHubLabel -Owner Mary -Repository WebApps

    .EXAMPLE
    # Retrieve only the label 'Label1' from the repository Mary/WebApps:
    Get-GitHubLabel -Owner Mary -Repository WebApps -Name Label1

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'Repository')]
        [Alias('User')]
        [string] $Owner
        , [Parameter(Mandatory = $true, ParameterSetName = 'Repository')]
        [string] $Repository
        , [Parameter(Mandatory = $false, ParameterSetName = 'Repository')]
        [string] $Name
        , [Parameter()]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $Page
    )

    $restMethod = 'repos/{0}/{1}/labels' -f $Owner, $Repository

    if ($Name) {
        $restMethod += ("/{0}" -f $Name)
    }

    $queryParameters = @()
    if ($Page) {
        $queryParameters += "page=$Page"
    }

    if ($queryParameters) {
        $restMethod += "?" + ($queryParameters -join '&')
    }

    $apiCall = @{
        Headers    = @{
            Accept = 'application/vnd.github.symmetra-preview+json'
        }
        Method     = 'Get'
        RestMethod = $restMethod
    }

    Invoke-GitHubApi @apiCall
}

