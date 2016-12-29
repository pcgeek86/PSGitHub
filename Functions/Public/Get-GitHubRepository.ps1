function Get-GitHubRepository 
{
    <#
    .SYNOPSIS
        This cmdlet will get the information about a GitHub repo.
    
    .DESCRIPTION
        This cmdlet can get the information about the github repo you specify with owner and GitHub repo name
        See https://developer.github.com/v3/repos/#get for detail

    .PARAMETER Owner
        The owner of the repo, default to be the authenticated user

    .PARAMETER Repository
        The name of the GitHub repository (not full name)

    .OUTPUTS
        Return a PSCustomObject. 
        See the return in https://developer.github.com/v3/repos/#get for detail
    
    .EXAMPLE
        PS C:\> Get-GitHubRepository -Owner octocat -Repository Hello-World
        the return of this statement is shown in https://developer.github.com/v3/repos/#get
    
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string] $Owner = (Get-GitHubAuthenticatedUser).login,
        [Parameter(Mandatory = $true)]
        [string] $Repository
    )
    
    begin 
    {
        
    }
    
    process
    {
        $apiCall = @{
            RestMethod = "repos/{0}/{1}" -f $Owner, $Repository
            Method = 'Get'
        }
    }
    
    end
    {
        Invoke-GitHubApi @apiCall
    }
}
