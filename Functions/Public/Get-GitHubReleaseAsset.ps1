function Get-GitHubReleaseAsset {
    <#
    .SYNOPSIS
    This command gets the github 

    .DESCRIPTION
    This command gets the assets of a release via the following 2 Parameter:
        1. releaseid -- the release id
        2. id -- the asset id

    .PARAMETER Owner
    the Owner of the repo to retrieve the releases, defaults to the current authenticated user.

    .PARAMETER Repository
    The repo that you want to retrieve the release

    .PARAMETER ReleaseId
    the Id of the release to retrieve, optional 
    (cannot be used together with 'Id')

    .PARAMETER Id
    the Id of the asset to retrieve, optional 
    (cannot be used together with 'ReleaseId')

    .EXAMPLE
    # get the all assets for a release from PowerShell/vscode-powershell 
    C:\PS> Get-GithubReleaseAsset -Owner Powershell -Repository vscode-powershell -ReleaseId 6808217

    # get a specific asset
    C:\PS> Get-GithubReleaseAsset -Owner Powershell -Repository vscode-powershell -Id 4163551

    .NOTES
    you cannot use parameter 'ReleaseId', 'Id' together

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [String] $Owner,
        [Parameter(Mandatory = $true)]
        [string] $Repository,
        [Parameter(Mandatory = $true, ParameterSetName = 'ReleaseId')]
        [String] $ReleaseId,
        [Parameter(Mandatory = $false, ParameterSetName = 'Id')]
        [String] $Id
    )
    
    begin {
    }
    
    process {
        # set the rest method
        switch ($PSCmdlet.ParameterSetName) {
            'ReleaseId' { $restMethod = "repos/$Owner/$Repository/releases/$ReleaseId/assets"; break; }
            'Id' { $restMethod = "repos/$Owner/$Repository/releases/assets/$Id"; break; }
            Default { $restMethod = "repos/$Owner/$Repository/releases/$ReleaseId/assets"; break; }
        }

        # set the API call parameter
        $apiCall = @{
            RestMethod = $restMethod
            Method = 'Get'
        }
    }
    
    end {
        # invoke the rest api call
        Invoke-GitHubApi @apiCall
    }
}
