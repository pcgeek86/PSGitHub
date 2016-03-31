function Get-GitHubGist {
    <#
    .Synopsis
    This command retrieves GitHub Gist.
    
    .Description
    This command is responsible for retrieving GitHub Gist.

    .Parameter Owner
    The Owner of the Gist to retrieve, defaults to the currently authenticated user.

    .Parameter Id
    The Id of the Gist to retreive.

    .Parameter Target
    Filters the Gists returned by Public or Starred only.

    .Example
    PS C:\> Get-GitHubGist -Id 62f8f608bdfec5d08552


    url          : https://api.github.com/gists/62f8f608bdfec5d08552
    forks_url    : https://api.github.com/gists/62f8f608bdfec5d08552/forks
    commits_url  : https://api.github.com/gists/62f8f608bdfec5d08552/commits
    id           : 62f8f608bdfec5d08552
    git_pull_url : https://gist.github.com/62f8f608bdfec5d08552.git
    git_push_url : https://gist.github.com/62f8f608bdfec5d08552.git
    html_url     : https://gist.github.com/62f8f608bdfec5d08552
    files        : @{Register-SophosWebIntelligenceService.ps1=}
    public       : True
    created_at   : 2016-03-16T14:39:29Z
    updated_at   : 2016-03-16T14:40:08Z
    description  : Fix for missing Sophos Web Intelligence Service
    comments     : 0
    user         : 
    comments_url : https://api.github.com/gists/62f8f608bdfec5d08552/comments
    owner        : @{login=dotps1; id=1016996; avatar_url=https://avatars.githubusercontent.com/u/1016996?v=3; gravatar_id=; url=https://api.github.com/users/dotps1; html_url=https://github.com/dotps1; followers_url=https://api.github.com/users/dotps1/followers; 
                   following_url=https://api.github.com/users/dotps1/following{/other_user}; gists_url=https://api.github.com/users/dotps1/gists{/gist_id}; starred_url=https://api.github.com/users/dotps1/starred{/owner}{/repo}; 
                   subscriptions_url=https://api.github.com/users/dotps1/subscriptions; organizations_url=https://api.github.com/users/dotps1/orgs; repos_url=https://api.github.com/users/dotps1/repos; events_url=https://api.github.com/users/dotps1/events{/privacy}; 
                   received_events_url=https://api.github.com/users/dotps1/received_events; type=User; site_admin=False}
    forks        : {}
    history      : {@{user=; version=369bffb9dd78b135b41047c2040b4b118d361545; committed_at=2016-03-16T14:40:08Z; change_status=; url=https://api.github.com/gists/62f8f608bdfec5d08552/369bffb9dd78b135b41047c2040b4b118d361545}, @{user=; version=6ea07bdaa15e1dae7e12013d5b29e6b6a9281ca7; 
                   committed_at=2016-03-16T14:39:29Z; change_status=; url=https://api.github.com/gists/62f8f608bdfec5d08552/6ea07bdaa15e1dae7e12013d5b29e6b6a9281ca7}}
    truncated    : False

    .Notes
    TODO: would like the ability to get gists by description or file name, possiably?
    Maybe to much to ask for.

    This cmdlet can be easily used with Save-GitHubGist and Set-GitHubGist.
      
    .Link
    https://trevorsullivan.net
    http://dotps1.github.io
    https://developer.github.com/v3/gists/
    #>

    [CmdletBinding(DefaultParameterSetName = '__AllParameterSets')]
    [OutputType([System.Object])]

    Param (
        [Parameter(ParameterSetName = 'Owner')]
        [String]$Owner = (Get-GitHubAuthenticatedUser).login,
        [Parameter(ParameterSetName = 'Id')]
        [String]$Id,
        [Parameter(ParameterSetName = 'Target')]
        [ValidateSet('Public', 'Starred')]
        [String]$Target
    )
    
    switch ($PSCmdlet.ParameterSetName) {
        'Owner' { $restMethod = 'users/{0}/gists' -f $Owner; break; }
        'Id' { $restMethod = 'gists/{0}' -f $Id; break; }
        'Target' { if ($Target -eq 'Public') { $restMethod = 'gists/public'} else { $restMethod = 'gists/starred' }; break; }
        default { $restMethod = 'gists'; break; }
    }

    $apiCall = @{
        #Body = ''
        RestMethod = $restMethod
        Method = 'Get'
    }
    
    foreach ($result in (Invoke-GitHubApi @apiCall)) {
        [GitHubGist]::new($result)
    }
}
