function Remove-GitHubReleaseAsset {
    <#
    .Synopsis
    This command deletes a GitHub release asset.

    .Description
    This command is responsible for deleting a GitHub release asset

    .PARAMETER Owner
        Optional, the Owner of the repo that you want to create the release on, default to the authenticated user

    .PARAMETER Repository
        Mandatory, the name of the Repository that you want to create the release on.

    .Parameter Id
    The Id of the Gist to remove or remove files from.

    .Example
    PS C:\> Remove-GitHubRelease -Owner 'test-organization' -Repository 'test-repo' -Id 1234567

    #>

    [CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess = $true)]
    [OutputType([Void])]

    Param (
        [Parameter(Mandatory = $true)]
        [string] $Owner,
        [Parameter(Mandatory = $true)]
        [string] $RepositoryName,
        [Parameter(Mandatory = $true)]
        [String] $Id,
        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    Process {
        $ApiCall = @{
            Uri    = "repos/$Owner/$RepositoryName/releases/assets/$Id"
            Method = 'delete'
            Token  = $Token
        }
    }

    end {
        if ($PSCmdlet.ShouldProcess($Id)) {
            Invoke-GitHubApi @ApiCall
        }
    }
}
