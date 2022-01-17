function New-GitHubRepository {
    <#
    .Synopsis
    Creates a new GitHub Repository, with the specified name.

    .Parameter Organization
    The name of the organization in that the GitHub repository will be created. If not given, will create a repository for the current user.

    .Parameter Name
    The name of the new GitHub repository that will be created. This is the only required parameter in order to instantiate a new GitHub Repository. The other parameters are optional, but recommended.

    .Parameter Description
    A user-friendly "plain English" description to help people understand the purpose of the GitHub repository.

    .Parameter Homepage
    The home page for the product or service that the project belongs to (eg. https://mycoolsoftwareproject.com).

    .Parameter IncludeReadme
    Indicates that a stub README.MD Markdown file should be generated when the repository is created.

    .Parameter DisableIssues
    If this parameter is present, then the GitHub Issue Tracker will be disable for the new GitHub Repository.

    .Parameter Private
    If this switch parameter is present, then the repository will be created as a Private (non-public) repository.

    .Notes
    Created by Trevor Sullivan <trevor@trevorsullivan.net>
    #>
    [CmdletBinding(DefaultParameterSetName = 'User')]
    [OutputType('PSGitHub.Repository')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'Org')]
        [string] $Organization,

        # The id of the team that will be granted access to this repository.
        # This is only valid when creating a repository in an organization.
        [Parameter(ParameterSetName = 'Org')]
        [int] $TeamId,

        [Parameter(Mandatory, Position = 0)]
        [string] $Name,

        [string] $Description,
        [string] $Homepage,
        [switch] $Private,
        [switch] $IncludeReadme,
        [string] $GitIgnoreTemplate,
        [string] $LicenseTemplate,
        [switch] $DisableIssues,
        [switch] $DisableProjects,
        [switch] $DisableWiki,
        [switch] $DisableSquashMerge,
        [switch] $DisableMergeCommit,
        [switch] $DisableRebaseMerge,
        [switch] $DeleteBranchOnMerge,
        [switch] $IsTemplate,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    $Body = @{
        name = $Name
        description = $Description
        homepage = $Homepage
        private = [bool]$Private
        auto_init = [bool]$IncludeReadme
        gitignore_template = $GitIgnoreTemplate
        license_template = $LicenseTemplate
        has_wiki = -not $DisableWiki
        has_issues = -not $DisableIssues
        allow_squash_merge = -not $DisableSquashMerge
        allow_merge_commit = -not $DisableMergeCommit
        allow_rebase_merge = -not $DisableRebaseMerge
        delete_branch_on_merge = [bool]$DeleteBranchOnMerge
        is_template = [bool]$IsTemplate
    }
    if ($DisableProjects) {
        $Body.has_projects = -not $DisableProjects
    }
    if ($TeamId) {
        $Body.team_id = $TeamId
    }

    $uri = if ($Organization) {
        "orgs/$Organization/repos"
    } else {
        "user/repos"
    }
    $templatePreview = 'application/vnd.github.baptiste-preview+json'
    Invoke-GitHubApi -Method POST $uri -Body ($Body | ConvertTo-Json) -Accept $templatePreview -BaseUri $BaseUri -Token $Token | ForEach-Object {
        $_.PSTypeNames.Insert(0, 'PSGitHub.Repository')
        $_.Owner.Insert(0, 'PSGitHub.User')
        $_
    }
}
