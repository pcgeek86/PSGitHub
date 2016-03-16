function Set-GitHubRepository {
    <#
    .Synopsis
    Updates the details for an existing GitHub repository.

    .Description
    This function updates the details for an existing GitHub repository. The parameters on this function enable you to
    update the repository's attributes including:

      - Name
      - Description
      - Project Page URI (Home Page)
      - Enable or Disable the Issue Tracker for this Repository
      - Switch the GitHub Repository between private and public access

    GitHub REST API documentation: https://developer.github.com/v3/repos

    .Parameter Owner
    The GitHub username of the account that owns the target repository.

    .Parameter Name
    The name of the existing GitHub Repository that will be operated on.

    .Parameter NewName
    This parameter allows you to specify a new name for the GitHub repository.

    .Parameter Description
    The new description that you'd like to set for the GitHub Repository. This will replace any existing description.

    .Parameter Homepage
    The URI to the project's home page. This will replace any existing value for the project home page.

    .Parameter DisableIssues
    This boolean parameter enables ($false) or disables ($true) the Issue Tracker for the GitHub Repository.

    .Parameter Private
    This boolean parameter makes the GitHub Repository public ($false) or private ($true).

    .Notes
    Created by Trevor Sullivan <trevor@trevorsullivan.net>
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string] $Owner
      , [Parameter(Mandatory = $true)]
        [string] $Name
      , [Parameter(Mandatory = $false)]
        [string] $NewName
      , [Parameter(Mandatory = $false)]
        [string] $Description
      , [Parameter(Mandatory = $false)]
        [string] $Homepage
      , [Parameter(Mandatory = $false)]
        [Boolean] $DisableIssues
      , [Parameter(Mandatory = $false)]
        [Boolean] $Private
    )

    $Body = @{
        name = if ($NewName) { $NewName } else { $Name };
        description = $Description;
        homepage = $Homepage;
        private = [bool]$Private;
        has_issues = [bool]!$DisableIssues;
        auto_init = [bool]$IncludeReadme;
        } | ConvertTo-Json;
    Write-Verbose -Message $Body;

    $ApiCall = @{
        RestMethod = 'repos/{0}/{1}' -f $Owner, $Name;
        Body = $Body;
        Method = 'Patch';
        }
    Invoke-GitHubApi @ApiCall;
}
