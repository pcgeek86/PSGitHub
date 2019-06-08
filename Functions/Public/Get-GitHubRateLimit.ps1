function Get-GitHubRateLimit {
    [OutputType('PSGitHub.RateLimit')]
    [CmdletBinding()]
    param (
        [Security.SecureString] $Token
    )

    Invoke-GitHubApi '/rate_limit' -Token $Token | ForEach-Object {
        $_.PSTypeNames.Insert(0, 'PSGitHub.RateLimit')
        foreach ($resourceName in $_.Resources.PSObject.Properties.Name) {
            $resource = $_.Resources.$resourceName
            $resource.Reset = [System.DateTimeOffset]::FromUnixTimeSeconds($resource.Reset).DateTime
            $resource.PSTypeNames.Insert(0, 'PSGitHub.RateLimitResource')
        }
        $_.Resources.PSTypeNames.Insert(0, 'PSGitHub.RateLimitResources')
        $_
    }
}
