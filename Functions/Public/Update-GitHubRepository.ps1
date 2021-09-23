function Update-GitHubRepository {
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

    .Parameter Rename
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
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Owner,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $RepositoryName,

        [Alias('NewName')]
        [string] $Rename,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Description,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Homepage,

        [Boolean] $DisableIssues,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Boolean] $Private,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $DefaultBranch,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    process {
        $body = @{ }

        if ($Rename) {
            $body.name = $Rename
        }
        if ($Description) {
            $body.description = $Description;
        }
        if ($Homepage) {
            $body.homepage = $Homepage;
        }
        if ($PSBoundParameters.ContainsKey('Private')) {
            $body.private = [bool]$Private;
        }
        if ($PSBoundParameters.ContainsKey('DisableIssues')) {
            $body.has_issues = -not $DisableIssues;
        }
        if ($DefaultBranch) {
            $body.default_branch = $DefaultBranch
        }

        $ApiCall = @{
            Uri = 'repos/{0}/{1}' -f $Owner, $Name;
            Body = $body | ConvertTo-Json;
            Method = 'Patch';
            Token = $Token
            BaseUri = $BaseUri
        }

        $shouldProcessCaption = "Updating GitHub repository"
        $shouldProcessDescription = "Updating GitHub repository `e[1m$Owner/$RepositoryName`e[0m."
        $shouldProcessWarning = "Do you want to update the GitHub repository `e[1m$Owner/$RepositoryName`e[0m?"

        if ($PSCmdlet.ShouldProcess($shouldProcessDescription, $shouldProcessWarning, $shouldProcessCaption)) {
            Invoke-GitHubApi @ApiCall | ForEach-Object {
                $_.PSTypeNames.Insert(0, 'PSGitHub.Repository')
                $_.Owner.PSTypeNames.Insert(0, 'PSGitHub.User')
                if ($_.License) {
                    $_.License.PSTypeNames.Insert(0, 'PSGitHub.License')
                }
                $_
            }
        }
    }
}

Export-ModuleMember -Alias (
    New-Alias -Name Set-GitHubRepository -Value Update-GitHubRepository -PassThru
)
