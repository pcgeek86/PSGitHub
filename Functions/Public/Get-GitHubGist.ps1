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
    [CmdletBinding()]
    param (
    )
    
    $ApiCall = @{
        Body = '';
        RestMethod = '';
        Method = '';
    }
    
    Invoke-GitHubApi @ApiCall;
}