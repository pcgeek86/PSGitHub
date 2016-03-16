function Get-GitHubAuthenticatedUser {
    [OutputType([System.Object])]
    [CmdletBinding()]
    param (
    )

    $RestMethod = 'user';
    $Result = Invoke-GitHubApi -RestMethod  -Method Default;
    $Result | ConvertFrom-Json
}
