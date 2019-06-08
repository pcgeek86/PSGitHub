function New-GitHubReleaseAsset {
    <#
    .SYNOPSIS
        Create a new GitHub release asset

    .DESCRIPTION
        Create a GitHub release asset for a given release

    .PARAMETER Owner
        Optional, the Owner of the repo that you want to create the release on, default to the authenticated user

    .PARAMETER Repository
        Mandatory, the name of the Repository that you want to create the release on.

    .PARAMETER ReleaseId
        Mandatory, the name of the tag of this release

    .PARAMETER Path
        Optional, specify the branch of the tag, default to the default branch (usually `master`)

    .PARAMETER ContentType
        Optional, the SHA of the commit that correspond to the tag

    .EXAMPLE
        Create a new release asset in release with id 1234567 of project 'test-organization/test-repo'
        PS C:\> New-GitHubRelease -Owner 'test-organization' -RepositoryName 'test-repo' -ReleaseId 1234567 -Path .\myasset.zip

    .NOTES
        1. This cmdlet will not help you create a tag, you need to use git to do that.
        2. This cmdlet will not help you to upload assets to the release, you need to use other functions to do that
        3. If both `Branch` and `CommitSHA` are provided, the release will be created based on the `Branch`
        4. If a relase with the same tag already exist and it is not a draft, this method will fail

    #>
    [CmdletBinding()]
    param(
        [string] $Owner = (Get-GitHubUser).login,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[\w-]+$')]
        [Alias('Repository')]
        [string] $RepositoryName,

        [Parameter(Mandatory)]
        [string] $ReleaseId,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [string] $Path,

        [string] $ContentType = 'application/zip',

        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    process {
        ### check path of asset
        if (-Not (Test-Path -Path $Path)) {
            Write-Error "Failed to locate asset at $Path"
        }

        ### extract name
        $Name = Get-Item -Path $Path | Select-Object -ExpandProperty Name

        ### create a API call
        $apiCall = @{
            Body = Get-Content -Path $Path -Raw
            Headers = @{'Content-Type' = $ContentType }
            Method = 'post'
            Uri = "https://uploads.github.com/repos/$Owner/$RepositoryName/releases/$ReleaseId/assets?name=$Name&label=$Name"
            Token = $Token
        }

        # invoke the api call
        Invoke-GitHubApi @apiCall
    }
}
