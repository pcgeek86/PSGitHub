function Get-GitHubRepository
{
    <#
    .SYNOPSIS
        This cmdlet will get the information about a GitHub repo.

    .DESCRIPTION
        This cmdlet can get the information for one or more github repos you specify with owner and GitHub repo name
        See https://developer.github.com/v3/repos/#get for detail

    .PARAMETER Owner
        The owner of the repo, default to be the authenticated user. When used by itself, retrieves the information for all (public - unless the authenticated user is specified) repos for the specified owner.
    .PARAMETER Repository
        The name of the GitHub repository (not full name)

    .PARAMETER License
        When this switch is turned on, you will only get the info about the license of the repository. Can be used only when specifying the Respository Parameter.

    .PARAMETER ReadMe
        When this switch is turned on, you will only get the info about the README of the repository. Can be used only when specifying hte Repository Parameter.

    .OUTPUTS
        Return a PSCustomObject.
        See the return in https://developer.github.com/v3/repos/#get for detail

    .EXAMPLE
        PS C:\> Get-GitHubRepository -Owner octocat -Repository Hello-World
        the return of this statement is shown in https://developer.github.com/v3/repos/#get

    .EXAMPLE
        PS C:\> Get-GitHubRepository
        Returns all respositories for the authenticated user

    .EXAMPLE
        PS C:\> Get-GitHubRepository -Owner exactmike
        Returns all respositories for the specified user

    .EXAMPLE
        PS C:\> Get-GitHubRepository -Owner exactmike -Repository OutSpeech -License
        Returns the license information for the specified owner's repository

    .EXAMPLE
        PS C:\> Get-GitHubRepository -Owner exactmike -Repository OutSpeech -ReadMe
        Returns the ReadMe information for the specified owner's repository
    #>

    [CmdletBinding(DefaultParameterSetName = 'AllForOwner')]
    param(
        [Parameter(ParameterSetName = 'AllForOwner')]
        [Parameter(Mandatory = $true,ParameterSetName = 'SpecificOwnerAndRepository')]
        [Parameter(Mandatory = $true,ParameterSetName = 'SpecificOwnerAndRepositoryReadMe')]
        [Parameter(Mandatory = $true,ParameterSetName = 'SpecificOwnerAndRepositoryLicense')]
        [string] $Owner = (Get-GitHubAuthenticatedUser).login,
        [Parameter(Mandatory = $true,ParameterSetName = 'SpecificOwnerAndRepository')]
        [Parameter(Mandatory = $true,ParameterSetName = 'SpecificOwnerAndRepositoryReadMe')]
        [Parameter(Mandatory = $true,ParameterSetName = 'SpecificOwnerAndRepositoryLicense')]
        [string] $Repository,
        [Parameter(Mandatory,ParameterSetName = 'SpecificOwnerAndRepositoryLicense')]
        [switch] $License,
        [Parameter(Mandatory,ParameterSetName = 'SpecificOwnerAndRepositoryReadMe')]
        [switch] $ReadMe
    )

    begin
    {
      switch -Wildcard ($PSCmdlet.ParameterSetName) {
        'AllForOwner'
        {
            if ($Owner -eq $(Get-GitHubAuthenticatedUser).login)
            {
                $RestMethod = 'user/repos'
            }
            else
            {
                $RestMethod = 'users/{0}/repos' -f $Owner
            }
        }
        'SpecificOwnerAndRepository*'
        {
            $RestMethod = 'repos/{0}/{1}' -f $Owner, $Repository
        }
        'SpecificOwnerAndRepositoryReadMe'
        {
            $RestMethod += '/readme'
        }
        'SpecificOwnerAndRepositoryLicense'
        {
            $RestMethod += '/license'
        }
      }
    }

    process
    {
        $ApiCall = @{
            RestMethod = $RestMethod
            Method = 'Get'
        }
    }

    end
    {
        Invoke-GitHubApi @ApiCall
    }
}
