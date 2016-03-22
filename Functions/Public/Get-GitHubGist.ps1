function Get-GitHubGist {
    <#
    .Synopsis
    This command retrieves GitHub Gist code snippets.
    
    .Description
    This command is responsible for retrieving GitHub Gist code snippets.
    
    .Notes
    This command should probably support multiple parameter sets:
    
      - Get a single Gist (or specific revision of a Gist, as an optional parameter)
        - If retrieving a specific Gist, and it's larger than 1MB, get the non-truncated version
      - Get a list of Gists for a user
      - List all public Gists
      
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
        Body = ''
        RestMethod = $restMethod
        Method = 'Get'
    }
    
    Invoke-GitHubApi @apiCall
}