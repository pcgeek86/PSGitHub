function Find-GitHubUser {
    <#
    .SYNOPSIS
        Searches GitHub issues and pull requests by a search query.
    #>
    [CmdletBinding()]
    [OutputType('PSGitHub.User')]
    param(
        [Parameter(Mandatory)]
        [string] $Query,

        [ValidateSet('followers', 'repositories', 'joined')]
        [string] $Sort,

        [ValidateSet('asc', 'desc')]
        [Alias('Direction')]
        [string] $Order,

        [Security.SecureString] $Token
    )

    process {
        $params = @{
            q = $Query
            sort = $Sort
            order = $Order
        }
        Invoke-GitHubApi '/search/users' -Body $params -Token $Token |
            ForEach-Object { $_.items } |
            ForEach-Object {
                $_.PSTypeNames.Insert(0, 'PSGitHub.User')
                $_
            }
    }
}

Export-ModuleMember -Alias @(
    (New-Alias -Name Search-GitHubUsers -Value Find-GitHubUser -PassThru),
    (New-Alias -Name Find-GitHubOrganization -Value Find-GitHubUser -PassThru),
    (New-Alias -Name Search-GitHubOrganizations -Value Find-GitHubUser -PassThru)
)
