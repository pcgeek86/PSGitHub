function Remove-GitHubLabel {
    <#
    .SYNOPSIS
    Remove a GitHub label.

    .DESCRIPTION
    This command removes a GitHub label from the specified repository using
    the authenticated user.

    .PARAMETER Owner
    The GitHub username of the account or organization that owns the GitHub
    repository specified in the parameter -Repository parameter.

    .PARAMETER Repository
    The name of the GitHub repository, that is owned by the GitHub username
    specified by parameter -Owner.

    .PARAMETER Name
    The name of the label to remove from the GitHub repository specified by the
    parameters -Owner and -Repository.

    .PARAMETER Force
    Forces the execution without confirmation prompts.

    .EXAMPLE
    # date the label name.
    Remove-GitHubLabel -Owner Mary -Repository WebApps -Name 'Label1'

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
      , [Parameter()]
        [switch] $Force
    )

    $shouldProcessCaption = 'Remove an existing GitHub label'
    $shouldProcessDescription = 'Removing the GitHub label ''{0}'' in the repository ''{1}/{2}''.' -f $Name, $Owner, $Repository
    $shouldProcessWarning = 'Do you want to remove the GitHub label ''{0}'' in the repository ''{1}/{2}''?' -f $Name, $Owner, $Repository

    if ($Force -or $PSCmdlet.ShouldProcess($shouldProcessDescription, $shouldProcessWarning, $shouldProcessCaption)) {
        $restMethod = 'repos/{0}/{1}/labels/{2}' -f $Owner, $Repository, $Name

        $apiCall = @{
            Headers =  @{
                'Accept' = 'application/vnd.github.symmetra-preview+json'
            }
            Method = 'Delete'
            RestMethod = $restMethod
        }

        # Variable scope ensures that parent session remains unchanged
        $ConfirmPreference = 'None'

        Invoke-GitHubApi @apiCall
    }
}
