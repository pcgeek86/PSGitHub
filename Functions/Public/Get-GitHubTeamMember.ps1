function Get-GitHubTeamMember {
    <#
    .SYNOPSIS
        Gets members of a GitHub team.
    #>
    [CmdletBinding()]
    [OutputType('PSGitHub.User')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $TeamId,

        [ValidateSet('member', 'maintainer', 'all')]
        [string] $Role,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token
    )

    process {
        $params = @{ }
        if ($Role) {
            $params.role = $Role
        }
        Invoke-GitHubApi "teams/$TeamId/members" -Body $params -BaseUri $BaseUri -Token $Token |
            ForEach-Object { $_ } |
            ForEach-Object {
                $_.PSTypeNames.Insert(0, 'PSGitHub.Team')
                $_
            }
    }
}
