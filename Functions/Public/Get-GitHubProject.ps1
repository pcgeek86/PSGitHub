function Get-GitHubProject {
    <#
    .SYNOPSIS
        Gets a GitHub project.
    #>
    [CmdletBinding()]
    [OutputType('PSGitHub.Project')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Repo', ValueFromPipelineByPropertyName)]
        [string] $Owner,

        [Parameter(Mandatory, ParameterSetName = 'Repo', ValueFromPipelineByPropertyName)]
        [string] $RepositoryName,

        [Parameter(Mandatory, ParameterSetName = 'Org', ValueFromPipelineByPropertyName)]
        [string] $OrganizationName,

        [Parameter(Mandatory, ParameterSetName = 'Id', ValueFromPipelineByPropertyName)]
        [int] $ProjectId,

        [string] $Name,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token
    )

    process {
        $url = switch ($PSCmdlet.ParameterSetName) {
            'Repo' {
                "repos/$Owner/$RepositoryName/projects"
            }
            'Org' {
                "orgs/$OrganizationName/projects"
            }
            'Id' {
                "projects/$ProjectId"
            }
        }
        Invoke-GitHubApi $url -Accept 'application/vnd.github.inertia-preview+json' -BaseUri $BaseUri -Token $Token |
            ForEach-Object { $_ } |
            Where-Object { -not $Name -or $_.Name -like $Name } |
            ForEach-Object {
                $_.PSTypeNames.Insert(0, 'PSGitHub.Project')
                $_.Creator.PSTypeNames.Insert(0, 'PSGitHub.User')
                $_
            }
    }
}
