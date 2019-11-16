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
    [OutputType('PSGitHub.Gist')]

    Param (
        [Parameter(ParameterSetName = 'Owner')]
        [String]$Owner = (Get-GitHubUser -Token $Token).login,
        [Parameter(ParameterSetName = 'Id')]
        [String]$Id,
        [Parameter(ParameterSetName = 'Target')]
        [ValidateSet('Public', 'Starred')]
        [String]$Target,
        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    switch ($PSCmdlet.ParameterSetName) {
        'Owner' { $uri = 'users/{0}/gists' -f $Owner; break; }
        'Id' { $uri = 'gists/{0}' -f $Id; break; }
        'Target' { if ($Target -eq 'Public') { $uri = 'gists/public' } else { $uri = 'gists/starred' }; break; }
        default { $uri = 'gists'; break; }
    }

    $apiCall = @{
        Uri = $uri
        Method = 'Get'
        Token = $Token
        BaseUri = $BaseUri
    }

    Invoke-GitHubApi @apiCall | ForEach-Object { $_ } | ForEach-Object {
        $_.PSTypeNames.Insert(0, 'PSGitHub.Gist')
        $_.Owner.PSTypeNames.Insert(0, 'PSGitHub.User')
        $filesObj = $_.Files
        $filesMap = @{ }
        foreach ($fileName in $filesObj.PSObject.Properties.Name) {
            $file = $filesObj.$fileName
            $file.PSTypeNames.Insert(0, 'PSGitHub.GistFile')
            $filesMap[$fileName] = $file
        }
        $_.Files = $filesMap
        $_
    }
}
