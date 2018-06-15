function New-GitHubRelease {
    <#
    .SYNOPSIS
        Create a new GitHub release

    .DESCRIPTION
        Create a GitHub release for a given tag and this function will not creates the tag or upload assets

    .PARAMETER Owner
        Optional, the Owner of the repo that you want to create the release on, default to the authenticated user

    .PARAMETER Repository
        Mandatory, the name of the Repository that you want to create the release on.

    .PARAMETER TagName
        Mandatory, the name of the tag of this release

    .PARAMETER Branch
        Optional, specify the branch of the tag, default to the default branch (usually `master`)

    .PARAMETER CommitSHA
        Optional, the SHA of the commit that correspond to the tag

    .PARAMETER Name
        Optional, the name (title) of the release

    .PARAMETER ReleaseNote
        Optional, the Release note of the release

    .PARAMETER Draft
        Optional, a switch to indicate whether this release is a draft release

    .PARAMETER Prerelease
        Optional, a switch to indicate whether this release is a pre-release

    .EXAMPLE
        Create a new draft release in my 'test-organization/test-repo'
        PS C:\> New-GitHubRelease -Owner 'test-organization' -Repository 'test-repo' -TagName 'v1.0' -name 'awesome release' -ReleaseNote 'great release note'

    .NOTES
        1. This cmdlet will not help you create a tag, you need to use git to do that.
        2. This cmdlet will not help you to upload assets to the release, you need to use other functions to do that
        3. If both `Branch` and `CommitSHA` are provided, the release will be created based on the `Branch`
        4. If a relase with the same tag already exist and it is not a draft, this method will fail

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string] $Owner = (Get-GitHubAuthenticatedUser).login,
        [Parameter(Mandatory = $true)]
        [string] $Repository,
        [Parameter(Mandatory = $true)]
        [string] $TagName,
        [Parameter(Mandatory = $false)]
        [string] $Branch,
        [Parameter(Mandatory = $false)]
        [string] $CommitSHA,
        [Parameter(Mandatory = $false)]
        [string] $Name,
        [Parameter(Mandatory = $false)]
        [string] $ReleaseNote,
        [Parameter()]
        [switch] $Draft,
        [Parameter()]
        [switch] $PreRelease
    )

    begin {

    }

    process {
        ### create the request Body
        $RequestBody = @{}

        # add TagName
        $RequestBody.Add('tag_name', $TagName)

        # add target commitish
        # see this url for detail: https://developer.github.com/v3/repos/releases/#create-a-release
        if ($Branch) {
            $RequestBody.Add('target_commitish', $Branch)
        }
        elseif ($CommitSHA) {
            $RequestBody.Add('target_commitish', $CommitSHA)
        }

        # add name
        if ($Name) {
            $RequestBody.Add('name', $Name)
        }

        # add Body
        if ($ReleaseNote) {
            $RequestBody.Add('body', $ReleaseNote)
        }

        # add draft
        if ($Draft) {
            $RequestBody.Add('draft', $true)
        }

        # add pre-release
        if ($PreRelease) {
            $RequestBody.Add('prerelease', $true)
        }

        ### create a API call
        $apiCall =
        @{
            Body       = $RequestBody | ConvertTo-Json
            Method     = 'post'
            RestMethod = "repos/$Owner/$Repository/releases"
        }
    }

    end {
        # invoke the api call
        Invoke-GitHubApi @apiCall
    }
}

