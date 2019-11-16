function Get-GitHubRateLimit {
    [OutputType('PSGitHub.RateLimit')]
    [CmdletBinding()]
    param (
        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token
    )

    Invoke-GitHubApi 'rate_limit' -BaseUri $BaseUri -Token $Token | ForEach-Object {
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
