function Get-GitHubAuthenticatedUser {
    [OutputType([System.Object])]
    [CmdletBinding()]
    param (
        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    $Uri = 'user'
    $Result = Invoke-GitHubApi -Uri $Uri -Method Default
    $Result
}
