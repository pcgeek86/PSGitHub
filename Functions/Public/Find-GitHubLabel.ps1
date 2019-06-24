function Find-GitHubLabel {
    <#
    .SYNOPSIS
        Searches GitHub labels for a repository by a search query.
    .INPUTS
        PSGitHub.Repository
    #>
    [CmdletBinding()]
    [OutputType('PSGitHub.Label')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [int] $RepositoryId,

        [Parameter(Mandatory, Position = 0)]
        [string] $Query,

        [ValidateSet('created', 'updated')]
        [string] $Sort,

        [ValidateSet('asc', 'desc')]
        [Alias('Direction')]
        [string] $Order,

        [Security.SecureString] $Token
    )

    process {
        $params = @{
            repository_id = $RepositoryId
            q = $Query
            sort = $Sort
            order = $Order
        }
        $headers = @{
            Accept = 'application/vnd.github.symmetra-preview+json'
        }
        Invoke-GitHubApi '/search/labels' -Body $params -Token $Token -Headers $headers |
            ForEach-Object { $_.items } |
            ForEach-Object {
                $_.PSTypeNames.Insert(0, 'PSGitHub.Label')
                $_
            }
    }
}

Export-ModuleMember -Alias (
    New-Alias -Name Search-GitHubLabels -Value Find-GitHubLabel -PassThru
)
