function New-GitHubReleaseAsset {
    <#
    .SYNOPSIS
        Create a new GitHub release asset

    .DESCRIPTION
        Create a GitHub release asset for a given release

    .PARAMETER Owner
        Optional, the Owner of the repo that you want to upload the release asset for, default to the authenticated user

    .PARAMETER Repository
        Mandatory, the name of the Repository that you want to upload the release asset for.

    .PARAMETER ReleaseId
        Mandatory, the name of the tag of this release

    .PARAMETER Path
        Optional, specify the branch of the tag, default to the default branch (usually `master`)

    .PARAMETER ContentType
        Mandatory, the content type of the file.

    .INPUTS
        PSGitHub.Release

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
        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token = (Get-GitHubToken),

        [Parameter(ParameterSetName = 'NoUploadUrl', ValueFromPipelineByPropertyName)]
        [string] $Owner = (Get-GitHubUser -Token $Token -BaseUri $BaseUri).login,

        [Parameter(Mandatory, ParameterSetName = 'NoUploadUrl', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[\w-\.]+$')]
        [Alias('Repository')]
        [string] $RepositoryName,

        [Parameter(Mandatory, ParameterSetName = 'NoUploadUrl')]
        [string] $ReleaseId,

        [Parameter(Mandatory, DontShow, ParameterSetName = 'UploadUrl', ValueFromPipelineByPropertyName)]
        [string] $UploadUrl,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [string] $Path,

        [string] $Label,

        [string] $ContentType = 'application/zip' # TODO this is not a good default.
    )

    process {
        $name = (Get-Item -Path $Path -Force -ErrorAction Stop).Name
        if (-not $Label) {
            $Label = $name
        }

        # Get upload URL from release object
        if (-not $UploadUrl) {
            $UploadUrl = (Get-GitHubRelease -Owner $Owner -RepositoryName $RepositoryName -Id $ReleaseId -Token $Token -BaseUri $BaseUri -ErrorAction Stop).UploadUrl
        }

        Write-Verbose "Expanding upload URL $UploadUrl with name=`"$name`" and label=`"$label`""

        # Expand query parameters in upload URL
        if ($UploadUrl -match '\{\?(.+)\}') {
            $vars = @{ name = $name; label = $Label }
            $allowedVars = $Matches[1] -split ','
            $query = '?' + (($allowedVars | ForEach-Object {
                if ($vars.ContainsKey($_)) {
                    $value = [System.Web.HttpUtility]::UrlEncode($vars[$_])
                    "$_=$value"
                }
            }) -join '&')
            $UploadUrl = $UploadUrl -replace '\{\?.+\}', $query
        }

        $apiCall = @{
            InFile = $Path
            Headers = @{'Content-Type' = $ContentType }
            Method = 'post'
            Uri = $UploadUrl
            Token = $Token
            BaseUri = $BaseUri
        }

        Invoke-GitHubApi @apiCall
    }
}
