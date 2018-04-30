function Set-GitHubLabel {
    <#
    .SYNOPSIS
    Update a GitHub label.

    .DESCRIPTION
    This command updates a GitHub label in the specified repository using
    the authenticated user.

    .PARAMETER Owner
    The GitHub username of the account or organization that owns the GitHub
    repository specified in the parameter -Repository parameter.

    .PARAMETER Repository
    The name of the GitHub repository, that is owned by the GitHub username
    specified by parameter -Owner.

    .PARAMETER Name
    The name of the label to update in the GitHub repository specified by the
    parameters -Owner and -Repository.

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
    Set-GitHubLabel -Owner Mary -Repository WebApps -Name 'Label1' -NewName 'NewLabelName'

    .EXAMPLE
    # Update the label color.
    Set-GitHubLabel -Owner Mary -Repository WebApps -Name 'good first issue' -Color '5319e7'

    .EXAMPLE
    # Update the label description.
    New-GitHubLabel -Owner Mary -Repository WebApps -Name 'good first issue' -Description 'The issue should be easier to fix and can be taken up by a beginner to learn to contribute on GitHub.'

    .EXAMPLE
    # Update all the label properties at the same time.
    New-GitHubLabel -Owner Mary -Repository WebApps -Name 'Label1' -NewName 'NewLabelName' -Color '5319e7' -Description 'Label description'

    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'Repository')]
        [Alias('User')]
        [string] $Owner
      , [Parameter(Mandatory = $true, ParameterSetName = 'Repository')]
        [string] $Repository
      , [Parameter(Mandatory = $true, ParameterSetName = 'Repository')]
        [string] $Name
      , [Parameter(Mandatory = $false, ParameterSetName = 'Repository')]
        [string] $NewName
      , [Parameter(Mandatory = $false, ParameterSetName = 'Repository')]
        [string] $Color
      , [Parameter(Mandatory = $false, ParameterSetName = 'Repository')]
        [string] $Description
      , [Parameter()]
        [switch] $Force
    )

    $shouldProcessCaption = 'Updating an existing GitHub label'
    $shouldProcessDescription = 'Updating the GitHub label ''{0}'' in the repository ''{1}/{2}''.' -f $Name, $Owner, $Repository
    $shouldProcessWarning = 'Do you want to update the GitHub label ''{0}'' in the repository ''{1}/{2}''?' -f $Name, $Owner, $Repository

    if ($Force -or $PSCmdlet.ShouldProcess($shouldProcessDescription, $shouldProcessWarning, $shouldProcessCaption)) {
        $restMethod = 'repos/{0}/{1}/labels/{2}' -f $Owner, $Repository, $Name

        $bodyProperties = @{}

        if ($NewName) {
            $bodyProperties['name'] = $NewName
        }

        if ($Color) {
            $bodyProperties['color'] = $Color
        }

        if ($Description) {
            $bodyProperties['description'] = $Description
        }

        $apiCall = @{
            Headers =  @{
                Accept = 'application/vnd.github.symmetra-preview+json'
            }
            Method = 'Patch'
            RestMethod = $restMethod
            Body = $bodyProperties | ConvertTo-Json
        }

        # Variable scope ensures that parent session remains unchanged
        $ConfirmPreference = 'None'

        Invoke-GitHubApi @apiCall
    }
}
