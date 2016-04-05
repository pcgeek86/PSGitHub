function Get-GitHubAuthenticatedUser {
    [OutputType([GitHubOwner])]
    [CmdletBinding()]
    param (
    )

    $RestMethod = 'user'
    $Result = Invoke-GitHubApi -RestMethod $RestMethod -Method Default
    [GitHubOwner]::new($Result)
}
