function Get-GitHubTeam {
    <#
    .SYNOPSIS
        Gets a GitHub team
    #>
    [CmdletBinding()]
    [OutputType('PSGitHub.Team')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $OrganizationName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Slug,

        [Security.SecureString] $Token
    )

    process {
        $url = "/orgs/$OrganizationName/teams"
        if ($Slug) {
            $url += "/$Slug"
        }
        Invoke-GitHubApi $url -Token $Token |
            ForEach-Object { $_ } |
            ForEach-Object {
                $_.PSTypeNames.Insert(0, 'PSGitHub.Team')
                if ($_.Organization) {
                    $_.Organization.PSTypeNames.Insert(0, 'PSGitHub.Organization')
                }
                $_
            }
    }
}
