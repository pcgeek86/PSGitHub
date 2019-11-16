function Get-GitHubRepository {
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
        PS C:\> Get-GitHubRepository -Owner octocat -RepositoryName Hello-World
        the return of this statement is shown in https://developer.github.com/v3/repos/#get

    .EXAMPLE
        PS C:\> Get-GitHubRepository
        Returns all respositories for the authenticated user

    .EXAMPLE
        PS C:\> Get-GitHubRepository -Owner exactmike
        Returns all respositories for the specified user

    .EXAMPLE
        PS C:\> Get-GitHubRepository -Owner exactmike -RepositoryName OutSpeech -License
        Returns the license information for the specified owner's repository

    .EXAMPLE
        PS C:\> Get-GitHubRepository -Owner exactmike -RepositoryName OutSpeech -ReadMe
        Returns the ReadMe information for the specified owner's repository
    #>

    [CmdletBinding()]
    [OutputType('PSGitHub.Repository')]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Owner,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[\w-\.]+$')]
        [Alias('Repository')]
        [string] $RepositoryName,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    process {
        $uri = if ($RepositoryName) {
            "repos/$Owner/$RepositoryName"
        } elseif ($Owner) {
            "users/$Owner/repos"
        } else {
            'user/repos'
        }
        # expand arrays
        Invoke-GitHubApi $uri -BaseUri $BaseUri -Token $Token |
            ForEach-Object { $_ } |
            ForEach-Object {
                $_.PSTypeNames.Insert(0, 'PSGitHub.Repository')
                $_.Owner.PSTypeNames.Insert(0, 'PSGitHub.User')
                if ($_.License) {
                    $_.License.PSTypeNames.Insert(0, 'PSGitHub.License')
                }
                $_
            }
    }
}
