﻿function Find-GitHubRepository {
    <#
    .Synopsis
    This function searches for repositories on GitHub.

    .Parameter Sort
    Optional. Choose the property to sort on, for GitHub repository search results:

      - Default: Best match
      - Stars: Sort by the number of stars the repositories have
      - Forks: Sort by the number of forks the repositories have
      - Updated: Sort by the last update date/time of the repositories

    .Parameter Order
    Optional. Specify the order to sort search results.

      - Ascending
      - Descending

    .Link
    https://trevorsullivan.net
    https://developer.github.com/v3/search
    #>
    [CmdletBinding()]
    [OutputType('PSGitHub.Repository')]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string] $Query,

        [ValidateSet('stars', 'forks', 'updated', 'help-wanted-issues')]
        [Alias('SortBy')] # BC
        [string] $Sort,

        [ValidateSet('asc', 'desc')]
        [Alias('SortOrder')] # BC
        [Alias('Direction')]
        [string] $Order,

        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    $queryParams = @{
        q = $Query
    }
    if ($Sort) {
        $queryParams.Add('sort', $Sort);
    }
    if ($Order) {
        $queryParams.Add('order', $Order);
    }

    $ApiCall = @{
        Uri = 'search/repositories'
        Body = $queryParams
        Token = $Token
    }
    Invoke-GitHubApi @ApiCall | ForEach-Object { $_.items } | ForEach-Object {
        $_.PSTypeNames.Insert(0, 'PSGitHub.Repository')
        $_.Owner.PSTypeNames.Insert(0, 'PSGitHub.User')
        if ($_.License) {
            $_.License.PSTypeNames.Insert(0, 'PSGitHub.License')
        }
        $_
    }
}
