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

        [Security.SecureString] $Token
    )

    process {
        $params = @{ }
        if ($Role) {
            $params.role = $Role
        }
        Invoke-GitHubApi "/teams/$TeamId/members" -Body $params -Token $Token |
            ForEach-Object { $_ } |
            ForEach-Object {
                $_.PSTypeNames.Insert(0, 'PSGitHub.Team')
                $_
            }
    }
}
