function Get-GitHubUser {
    [OutputType('PSGitHub.User')]
    [CmdletBinding()]
    param (
        # Gets a specific user by username.
        # If not given, returns the authenticated user of the token.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Username,

        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    $url = if ($Username) {
        "/users/$Username"
    } else {
        "/user"
    }

    Invoke-GitHubApi $url -Token $Token | ForEach-Object {
        $_.PSTypeNames.Insert(0, 'PSGitHub.User')
        $_
    }
}

Export-ModuleMember -Alias (
    New-Alias -Name Get-GitHubAuthenticatedUser -Value Get-GitHubUser -PassThru
)
