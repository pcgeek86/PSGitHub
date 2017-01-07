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

    .PARAMETER General
        Default switch. When this switch is turned on, you will only get the general info of the repository
    
    .PARAMETER License
        When this switch is turned on, you will only get the info about the license of the repository

    .PARAMETER ReadMe 
        When this switch is turned on, you will only get the info about the README of the repository

    .OUTPUTS
        Return a PSCustomObject. 
        See the return in https://developer.github.com/v3/repos/#get for detail
    
    .EXAMPLE
        PS C:\> Get-GitHubRepository -Owner octocat -Repository Hello-World
        the return of this statement is shown in https://developer.github.com/v3/repos/#get
    
    #>

    [CmdletBinding(DefaultParameterSetName = 'general')]
    param(
        [Parameter(Mandatory = $false)]
        [string] $Owner = (Get-GitHubAuthenticatedUser).login,
        [Parameter(Mandatory = $true)]
        [string] $Repository,
        [Parameter(ParameterSetName = 'general')]
        [switch] $General,
        [Parameter(ParameterSetName = 'license')]
        [switch] $License,
        [Parameter(ParameterSetName = 'readme')]
        [switch] $ReadMe
    )
    
    begin 
    {
        switch ($PSCmdlet.ParameterSetName) {
            'general' { $restMethod = "repos/{0}/{1}" -f $Owner, $Repository}
            'license' { $restMethod = "repos/{0}/{1}/license" -f $Owner, $Repository}
            'readme' { $restMethod = "repos/{0}/{1}/readme" -f $Owner, $Repository}
            Default {}
        }
    }
    
    process
    {
        $apiCall = @{
            RestMethod = $restMethod
            Method = 'Get'
        }
    }
    
    end
    {
        Invoke-GitHubApi @apiCall
    }
}
