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
    https://developer.github.com/v3/gists/
    #>
    [CmdletBinding(
        DefaultParameterSetName = '__AllParameterSets'
    )]

    Param (
        [Parameter(
            ParameterSetName = 'Owner'
        )]
        [String]
        $Owner = (Get-GitHubAuthenticatedUser).login,

        [Parameter(
            ParameterSetName = 'Target'
        )]
        [ValidateSet(
            'Public',
            'Starred'
        )]
        [String]
        $Target,

        [Parameter(
            ParameterSetName = 'Id'
        )]
        [String]
        $Id
    )
    
    switch ($PSCmdlet.ParameterSetName) {
        'Owner' {
            $uri = 'users/{0}/gists' -f $Owner

            break
        }
        
        'Id' {
            $uri = 'gists/{0}' -f $Id

            break
        }

        'Target' {
            if ($Target -eq 'Public') {
                $uri = 'gists/public'
            } else {
                $uri = 'gists/starred'
            }

            break
        }

        default {
            $uri = 'gists'

            break
        }
    }

    $apiCall = @{
        Body = ''
        RestMethod = $uri
        Method = 'Get'
    }
    
    Invoke-GitHubApi @apiCall
}