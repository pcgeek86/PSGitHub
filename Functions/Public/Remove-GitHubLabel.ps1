function Remove-GitHubLabel {
    <#
    .SYNOPSIS
    Remove a GitHub label.

    .DESCRIPTION
    This command removes a GitHub label from the specified repository using
    the authenticated user.

    .PARAMETER Owner
    The GitHub username of the account or organization that owns the GitHub
    repository specified in the parameter -RepositoryName parameter.

    .PARAMETER Repository
    The name of the GitHub repository, that is owned by the GitHub username
    specified by parameter -Owner.

    .PARAMETER Name
    The name of the label to remove from the GitHub repository specified by the
    parameters -Owner and -RepositoryName.

    .PARAMETER Force
    Forces the execution without confirmation prompts.

    .EXAMPLE
    # date the label name.
    Remove-GitHubLabel -Owner Mary -RepositoryName WebApps -Name 'Label1'

    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'Repository')]
        [Alias('User')]
        [string] $Owner,

        [Parameter(Mandatory, ParameterSetName = 'Repository')]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[\w-\.]+$')]
        [Alias('Repository')]
        [string] $RepositoryName,

        [Parameter(Mandatory, ParameterSetName = 'Repository')]
        [string] $Name,

        [switch] $Force,

        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    $shouldProcessCaption = 'Remove an existing GitHub label'
    $shouldProcessDescription = 'Removing the GitHub label ''{0}'' in the repository ''{1}/{2}''.' -f $Name, $Owner, $RepositoryName
    $shouldProcessWarning = 'Do you want to remove the GitHub label ''{0}'' in the repository ''{1}/{2}''?' -f $Name, $Owner, $RepositoryName

    if ($Force -or $PSCmdlet.ShouldProcess($shouldProcessDescription, $shouldProcessWarning, $shouldProcessCaption)) {
        $uri = 'repos/{0}/{1}/labels/{2}' -f $Owner, $RepositoryName, $Name

        $apiCall = @{
            Headers = @{
                Accept = 'application/vnd.github.symmetra-preview+json'
            }
            Method = 'Delete'
            Uri = $uri
            Token = $Token
        }

        # Variable scope ensures that parent session remains unchanged
        $ConfirmPreference = 'None'

        Invoke-GitHubApi @apiCall
    }
}
