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
    C:\PS> Get-GithubReleaseAsset -Owner Powershell -RepositoryName vscode-powershell -ReleaseId 6808217

    # get a specific asset
    C:\PS> Get-GithubReleaseAsset -Owner Powershell -RepositoryName vscode-powershell -Id 4163551

    .NOTES
    you cannot use parameter 'ReleaseId', 'Id' together

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Release', ValueFromPipeline)]
        [ValidateScript( { $null -ne $_.PSObject.Properties['assets_url'] })]
        [object] $Release,

        [Parameter(Mandatory, ParameterSetName = 'Id')]
        [Parameter(Mandatory, ParameterSetName = 'ReleaseId')]
        [String] $Owner,

        [Parameter(Mandatory, ParameterSetName = 'Id')]
        [Parameter(Mandatory, ParameterSetName = 'ReleaseId')]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[\w-\.]+$')]
        [Alias('Repository')]
        [string] $RepositoryName,

        [Parameter(Mandatory, ParameterSetName = 'Id')]
        [String] $Id,

        [Parameter(Mandatory, ParameterSetName = 'ReleaseId')]
        [String] $ReleaseId,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    process {
        # set the rest method
        $uri = switch ($PSCmdlet.ParameterSetName) {
            'Release' { $Release.assets_url }
            'ReleaseId' { "repos/$Owner/$RepositoryName/releases/$ReleaseId/assets" }
            'Id' { "repos/$Owner/$RepositoryName/releases/assets/$Id" }
            Default { "repos/$Owner/$RepositoryName/releases/$ReleaseId/assets" }
        }

        # set the API call parameter
        $apiCall = @{
            Uri = $uri
            Method = 'Get'
            Token = $Token
            BaseUri = $BaseUri
        }
        Invoke-GitHubApi @apiCall
    }
}
