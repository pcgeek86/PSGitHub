Function Copy-GitHubGist {
    <#
    .Synopsis
    Forks a GitHub Gist.

    .Description
    Forks and existing GitHub Gist to the current users Gist colleciton.

    .Example
    # Fork Gist from pcgeek86.
    PS C:\> Get-GitHubGist -Id 23ad223dba5c36041e21 | Copy-GitHubGist


    Comments    : 0
    CommentsUrl : https://api.github.com/gists/f71b4ab6522af7cec700eb13248b82b2/comments
    CommitsUrl  : https://api.github.com/gists/f71b4ab6522af7cec700eb13248b82b2/commits
    CreatedAt   : 3/31/2016 11:41:57 PM
    Description : This Gist provides a suggested pattern for serializing / deserializing PowerShell v5 class instances
    Files       : {PowerShell v5 Class Serialization Pattern.ps1}
    Forks       : 
    ForksUrl    : https://api.github.com/gists/f71b4ab6522af7cec700eb13248b82b2/forks
    History     : 
    HtmlUrl     : https://gist.github.com/f71b4ab6522af7cec700eb13248b82b2
    Id          : f71b4ab6522af7cec700eb13248b82b2
    Owner       : GitHubUser
    Public      : True
    PullUrl     : https://gist.github.com/f71b4ab6522af7cec700eb13248b82b2.git
    PushUrl     : https://gist.github.com/f71b4ab6522af7cec700eb13248b82b2.git
    Truncated   : False
    UpdatedAt   : 3/31/2016 11:41:57 PM
    Url         : https://api.github.com/gists/f71b4ab6522af7cec700eb13248b82b2

    # Shows where dotps1 was the user that forked the Gist.
    PS C:\> (Get-GitHubGist -Id 23ad223dba5c36041e21).Forks.User


    AvatarUrl         : https://avatars.githubusercontent.com/u/1016996?v=3
    EventsUrl         : https://api.github.com/users/dotps1/events{/privacy}
    FollowersUrl      : https://api.github.com/users/dotps1/followers
    FollowingUrl      : https://api.github.com/users/dotps1/following{/other_user}
    GistsUrl          : https://api.github.com/users/dotps1/gists{/gist_id}
    GravatarId        : 
    HtmlUrl           : https://github.com/dotps1
    Id                : 1016996
    Login             : dotps1
    OrganizationsUrl  : https://api.github.com/users/dotps1/orgs
    ReceivedEventsUrl : https://api.github.com/users/dotps1/received_events
    ReposUrl          : https://api.github.com/users/dotps1/repos
    SiteAdmin         : False
    StarredUrl        : https://api.github.com/users/dotps1/starred{/owner}{/repo}
    SubscriptionsUrl  : https://api.github.com/users/dotps1/subscriptions
    Type              : User
    Url               : https://api.github.com/users/dotps1

    .Notes
    This cmdlet has an alias: Fork-GitHubGist

    .Link
    https://trevorsullivan.net
    http://dotps1.github.io
    https://developer.github.com/v3/gists
    #>

    [OutputType([GitHubGist])]

    Param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [String[]]$Id
    )

    Process {
        foreach ($item in $Id) {
            $apiCall = @{
                #Body = ''
                RestMethod = 'gists/{0}/forks' -f $item
                Method = 'POST'
            }
    
            [GitHubGist]::new((Invoke-GitHubApi @apiCall))
        }
    }
}