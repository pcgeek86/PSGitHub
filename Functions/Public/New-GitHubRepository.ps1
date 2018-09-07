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
    If this switch parameter is present, then the repository will be created as a Private (non-public) repository. This requires a subscription to GitHub. Free accounts are eligible for public repositories only.

    .Notes
    Created by Trevor Sullivan <trevor@trevorsullivan.net>
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $Organization,
        [Parameter(Mandatory, Position = 0)]
        [string] $Name,
        [Parameter()]
        [string] $Description,
        [Parameter()]
        [string] $Homepage,
        [Parameter()]
        [switch] $IncludeReadme,
        [Parameter()]
        [string] $DisableIssues,
        [Parameter()]
        [string] $Private,
        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    $Body = @{
        name        = $Name;
        description = $Description;
        homepage    = $Homepage;
        private     = [bool]$Private;
        has_issues  = [bool]!$DisableIssues;
        auto_init   = [bool]$IncludeReadme;
    } | ConvertTo-Json;
    Write-Verbose -Message $Body;

    $uri = if ($Organization) {
        "orgs/$Organization/repos"
    }
    else {
        "user/repos"
    }
    Invoke-GitHubApi -Uri $uri -Body $Body -Method Post -Token $Token;
}
