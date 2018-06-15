function Get-GitHubRelease {
    <#
    .SYNOPSIS
    This command gets the github

    .DESCRIPTION
    This command gets the id of a release via the following 3 Parameter:
        1. id -- the release id
        2. tag name -- the release tag name
        3. latest -- the latest release

    .PARAMETER Owner
    the Owner of the repo to retrieve the releases, defaults to the current authenticated user.

    .PARAMETER Repository
    The repo that you want to retrieve the release

    .PARAMETER Id
    the Id of the release to retrieve, optional
    (cannot be used together with 'Latest' or 'TagName')

    .PARAMETER TagName
    the TagName of the release to retrieve, optional
    (cannot be used together with 'Id' or 'Latest')

    .PARAMETER Latest
    when this switch is on, the command will retrieve the latest release, optional
    (cannot be used together with 'Id' or 'TagName')

    .EXAMPLE
    # get the latest release from soimort/you-get
    C:\PS> Get-GithubRelease -Owner soimort -Repository you-get -Latest

    # get all the release from PowerShell/vscode-powershell
    C:\PS> Get-GithubRelease -Owner Powershell -Repository vscode-powershell

    # get the version 'v0.1.0' release from PowerShell/vscode-powershell
    C:\PS> Get-GithubRelease -Owner Powershell -Repository vscode-powershell -TagName v0.1.0

    # get the release with id 2161075 from PowerShell/vscode-powershell
    C:\PS> Get-GithubRelease -Owner Powershell -Repository vscode-powershell -Id 2161075

    .NOTES
    you cannot use parameter 'Id', 'Latest', 'TagName' together

    #>
    [CmdletBinding(DefaultParameterSetName = '__AllParameterSets')]
    param(
        [Parameter(Mandatory = $false)]
        [String] $Owner,
        [Parameter(Mandatory = $true)]
        [string] $Repository,
        [Parameter(Mandatory = $false, ParameterSetName = 'Id')]
        [String] $Id,
        [Parameter(Mandatory = $false, ParameterSetName = 'TagName')]
        [String] $TagName,
        [Parameter(Mandatory = $false, ParameterSetName = 'Latest')]
        [Switch] $Latest
    )

    begin {
    }

    process {
        # set the rest method
        switch ($PSCmdlet.ParameterSetName) {
            'Id' { $restMethod = "repos/$Owner/$Repository/releases/$Id"; break; }
            'TagName' { $restMethod = "repos/$Owner/$Repository/releases/tags/$TagName"; break; }
            'Latest' { $restMethod = "repos/$Owner/$Repository/releases/latest"; break; }
            Default { $restMethod = "repos/$Owner/$Repository/releases"; break; }
        }

        # set the API call parameter
        $apiCall = @{
            RestMethod = $restMethod
            Method     = 'Get'
        }
    }

    end {
        # invoke the rest api call
        Invoke-GitHubApi @apiCall
    }
}
