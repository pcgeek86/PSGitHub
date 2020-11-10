function Update-GitHubLabel {
    <#
    .SYNOPSIS
    Update a GitHub label.

    .DESCRIPTION
    This command updates a GitHub label in the specified repository using
    the authenticated user.

    .PARAMETER Owner
    The GitHub username of the account or organization that owns the GitHub
    repository specified in the parameter -RepositoryName parameter.

    .PARAMETER Repository
    The name of the GitHub repository, that is owned by the GitHub username
    specified by parameter -Owner.

    .PARAMETER Name
    The name of the label to update in the GitHub repository specified by the
    parameters -Owner and -RepositoryName.

    .PARAMETER NewName
    The new name of the label that is specified by the parameter -Name.
    It is possible to add emoji to label names, i.e. 'Good :strawberry:'.

    .PARAMETER Color
    The new color of the label that is specified by the parameter -Name.
    The color should be specified without the leading '#'.

   .PARAMETER Description
    The new description of the label that is specified by the parameter -Name.
    GitHub has limited the description to max 100 characters.

    .PARAMETER Force
    Forces the execution without confirmation prompts.

    .EXAMPLE
    # Update the label name.
    Set-GitHubLabel -Owner Mary -RepositoryName WebApps -Name 'Label1' -NewName 'NewLabelName'

    .EXAMPLE
    # Update the label color.
    Set-GitHubLabel -Owner Mary -RepositoryName WebApps -Name 'good first issue' -Color '5319e7'

    .EXAMPLE
    # Update the label description.
    New-GitHubLabel -Owner Mary -RepositoryName WebApps -Name 'good first issue' -Description 'The issue should be easier to fix and can be taken up by a beginner to learn to contribute on GitHub.'

    .EXAMPLE
    # Update all the label properties at the same time.
    New-GitHubLabel -Owner Mary -RepositoryName WebApps -Name 'Label1' -NewName 'NewLabelName' -Color '5319e7' -Description 'Label description'

    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ParameterSetName = 'Repository', ValueFromPipelineByPropertyName)]
        [Alias('User')]
        [string] $Owner,
        [Parameter(Mandatory, ParameterSetName = 'Repository', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[\w-\.]+$')]
        [Alias('Repository')]
        [string] $RepositoryName,
        [Parameter(Mandatory, ParameterSetName = 'Repository', ValueFromPipelineByPropertyName)]
        [string] $Name,
        [Parameter(ParameterSetName = 'Repository')]
        [string] $NewName,
        [Parameter(ParameterSetName = 'Repository', ValueFromPipelineByPropertyName)]
        [string] $Color,
        [Parameter(ParameterSetName = 'Repository', ValueFromPipelineByPropertyName)]
        [string] $Description,
        [switch] $Force,
        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    process {
        $shouldProcessCaption = 'Updating an existing GitHub label'
        $shouldProcessDescription = 'Updating the GitHub label ''{0}'' in the repository ''{1}/{2}''.' -f $Name, $Owner, $RepositoryName
        $shouldProcessWarning = 'Do you want to update the GitHub label ''{0}'' in the repository ''{1}/{2}''?' -f $Name, $Owner, $RepositoryName

        if ($Force -or $PSCmdlet.ShouldProcess($shouldProcessDescription, $shouldProcessWarning, $shouldProcessCaption)) {
            $uri = 'repos/{0}/{1}/labels/{2}' -f $Owner, $RepositoryName, $Name

            $bodyProperties = @{ }

            if ($NewName) {
                $bodyProperties['name'] = $NewName
            } else {
                $bodyProperties['name'] = $Name
            }

            if ($Color) {
                $bodyProperties['color'] = $Color
            }

            if ($Description) {
                $bodyProperties['description'] = $Description
            }

            $apiCall = @{
                Headers = @{
                    Accept = 'application/vnd.github.symmetra-preview+json'
                }
                Method = 'Patch'
                Uri = $uri
                Body = $bodyProperties | ConvertTo-Json
                Token = $Token
                BaseUri = $BaseUri
            }

            # Variable scope ensures that parent session remains unchanged
            $ConfirmPreference = 'None'

            Invoke-GitHubApi @apiCall | ForEach-Object {
                $_.PSTypeNames.Insert(0, 'PSGitHub.Label')
                $_
            }
        }
    }
}

Export-ModuleMember -Alias (
    New-Alias -Name Set-GitHubLabel -Value Update-GitHubLabel -PassThru
)
