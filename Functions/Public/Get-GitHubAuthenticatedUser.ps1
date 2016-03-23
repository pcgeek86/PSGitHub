function Get-GitHubAuthenticatedUser {
    [OutputType([System.Object])]
    [CmdletBinding()]
    param (
    )

    $RestMethod = 'user'
    $Result = Invoke-GitHubApi -RestMethod $RestMethod -Method Default
    $Result
}