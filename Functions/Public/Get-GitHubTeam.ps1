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

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token
    )

    process {
        $url = "orgs/$OrganizationName/teams"
        if ($Slug) {
            $url += "/$Slug"
        }
        Invoke-GitHubApi $url -BaseUri $BaseUri -Token $Token |
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
