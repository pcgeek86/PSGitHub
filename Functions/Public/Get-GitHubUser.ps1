function Get-GitHubUser {
    [OutputType('PSGitHub.User')]
    [CmdletBinding()]
    param (
        # Gets a specific user by username.
        # If not given, returns the authenticated user of the token.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Username,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    $url = if ($Username) {
        "users/$Username"
    } else {
        "user"
    }

    Invoke-GitHubApi $url -BaseUri $BaseUri -Token $Token | ForEach-Object {
        $_.PSTypeNames.Insert(0, 'PSGitHub.User')
        $_
    }
}

Export-ModuleMember -Alias (
    New-Alias -Name Get-GitHubAuthenticatedUser -Value Get-GitHubUser -PassThru
)
