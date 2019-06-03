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
    the Owner of the repo to retrieve the releases.

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
    C:\PS> Get-GithubRelease -Owner soimort -RepositoryName you-get -Latest

    # get all the release from PowerShell/vscode-powershell
    C:\PS> Get-GithubRelease -Owner Powershell -RepositoryName vscode-powershell

    # get the version 'v0.1.0' release from PowerShell/vscode-powershell
    C:\PS> Get-GithubRelease -Owner Powershell -RepositoryName vscode-powershell -TagName v0.1.0

    # get the release with id 2161075 from PowerShell/vscode-powershell
    C:\PS> Get-GithubRelease -Owner Powershell -RepositoryName vscode-powershell -Id 2161075

    .NOTES
    you cannot use parameter 'Id', 'Latest', 'TagName' together

    #>
    [CmdletBinding(DefaultParameterSetName = '__AllParameterSets')]
    [OutputType('PSGitHub.Release')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [String] $Owner,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[\w-]+$')]
        [Alias('Repository')]
        [string] $RepositoryName,
        [Parameter(ParameterSetName = 'Id')]
        [String] $Id,
        [Parameter(ParameterSetName = 'TagName')]
        [String] $TagName,
        [Parameter(ParameterSetName = 'Latest')]
        [Switch] $Latest,
        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    process {
        # set the URL
        $uri = switch ($PSCmdlet.ParameterSetName) {
            'Id' { "repos/$Owner/$RepositoryName/releases/$Id" }
            'TagName' { "repos/$Owner/$RepositoryName/releases/tags/$TagName" }
            'Latest' { "repos/$Owner/$RepositoryName/releases/latest" }
            Default { "repos/$Owner/$RepositoryName/releases" }
        }

        # set the API call parameter
        $apiCall = @{
            Uri = $uri
            Method = 'Get'
            Token = $Token
        }
        # invoke the rest api call
        Invoke-GitHubApi @apiCall | ForEach-Object { $_ } | ForEach-Object {
            $_.PSTypeNames.Insert(0, 'PSGitHub.Release')
            $_.Author.PSTypeNames.Insert(0, 'PSGitHub.User')
            $_
        }
    }
}
