function Get-GitHubUser {
    [OutputType('PSGitHub.User')]
    [CmdletBinding()]
    param (
        # Gets a specific user by username.
        # If not given, returns the authenticated user of the token.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'SpecificUser')]
        [string] $Username = '',

        [Parameter(ParameterSetName = 'ListAllUsers')]
        [switch] $All,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    switch ($PSCmdlet.ParameterSetName) {
        'SpecificUser' {
            $url = if ($Username -ne '') {
                "users/$Username"
            } else {
                "user"
            }
        
            $url = 'users/{0}' -f $Username
            break
        }
        'ListAllUsers' {
            $url = 'users'
            break
        }
    }

    Invoke-GitHubApi $url -BaseUri $BaseUri -Token $Token | ForEach-Object {
        $_.PSTypeNames.Insert(0, 'PSGitHub.User')
        $_
    }
}

Export-ModuleMember -Alias (
    New-Alias -Name Get-GitHubAuthenticatedUser -Value Get-GitHubUser -PassThru
)
