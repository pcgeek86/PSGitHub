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

        [Security.SecureString] $Token
    )

    process {
        $url = switch ($PSCmdlet.ParameterSetName) {
            'Repo' {
                "/repos/$Owner/$RepositoryName/projects"
            }
            'Org' {
                "/orgs/$OrganizationName/projects"
            }
            'Id' {
                "/projects/$ProjectId"
            }
        }
        Invoke-GitHubApi $url -Accept 'application/vnd.github.inertia-preview+json' -Token $Token |
            ForEach-Object { $_ } |
            Where-Object { -not $Name -or $_.Name -like $Name } |
            ForEach-Object {
                $_.PSTypeNames.Insert(0, 'PSGitHub.Project')
                $_.Creator.PSTypeNames.Insert(0, 'PSGitHub.User')
                $_
            }
    }
}
