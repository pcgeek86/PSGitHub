function New-GitHubLabel {
    <#
    .SYNOPSIS
    Create a GitHub label.

    .DESCRIPTION
    This command creates a GitHub label in the specified repository using
    the authenticated user.

    .PARAMETER Owner
    The GitHub username of the account or organization that owns the GitHub
    repository specified in the parameter -Repository parameter.

    .PARAMETER Repository
    The name of the GitHub repository, that is owned by the GitHub username
    specified by parameter -Owner.

    .PARAMETER Name
    The name of the label to create in the GitHub repository specified by the
    parameters -Owner and -Repository.
    It is possible to add emoji to label names, i.e. 'Good :strawberry:'.

    .PARAMETER Color
    The color of the label that is specified by the parameter -Name.
    The color should be specified without the leading '#'.

   .PARAMETER Description
    The description of the label that is specified by the parameter -Name.
    GitHub has limited the description to max 100 characters.

    .PARAMETER Force
    Forces the execution without confirmation prompts.

    .EXAMPLE
    # Create a label without description.
    New-GitHubLabel -Owner Mary -Repository WebApps -Name 'good first issue' -Color '5319e7'

    .EXAMPLE
    # Create a label without description using emoji.
    New-GitHubLabel -Owner Mary -Repository WebApps -Name 'Good :strawberry:' -Color 'ffffff'

    .EXAMPLE
    # Create a label with a description.
    New-GitHubLabel -Owner Mary -Repository WebApps -Name 'good first issue' -Color '5319e7' -Description 'The issue should be easier to fix and can be taken up by a beginner to learn to contribute on GitHub.'

    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'Repository')]
        [Alias('User')]
        [string] $Owner
      , [Parameter(Mandatory = $true, ParameterSetName = 'Repository')]
        [string] $Repository
      , [Parameter(Mandatory = $true, ParameterSetName = 'Repository')]
        [string] $Name
      , [Parameter(Mandatory = $true, ParameterSetName = 'Repository')]
        [string] $Color
      , [Parameter(Mandatory = $false, ParameterSetName = 'Repository')]
        [string] $Description
      , [Parameter()]
        [switch] $Force
    )

    $shouldProcessCaption = 'Creating new GitHub label'
    $shouldProcessDescription = 'Creating the GitHub label ''{0}'' in the repository ''{1}/{2}''.' -f $Name, $Owner, $Repository
    $shouldProcessWarning = 'Do you want to create the GitHub label ''{0}'' in the repository ''{1}/{2}''?' -f $Name, $Owner, $Repository

    if ($Force -or $PSCmdlet.ShouldProcess($shouldProcessDescription, $shouldProcessWarning, $shouldProcessCaption)) {
        $restMethod = 'repos/{0}/{1}/labels' -f $Owner, $Repository

        $bodyProperties = @{
            name = $Name
            color = $Color
        }

        if ($Description) {
            $bodyProperties['description'] = $Description
        }

        $apiCall = @{
            Method = 'Post'
            RestMethod = $restMethod
            Body = $bodyProperties | ConvertTo-Json
        }

        # Variable scope ensures that parent session remains unchanged
        $ConfirmPreference = 'None'

        Invoke-GitHubApi @apiCall
    }
}
