function New-GitHubGist {
    <#
    .Synopsis
    This command creates a new GitHub Gist code snippet.
    
    .Description
    This command is responsible for creating new GitHub Gist code snippets.
    
    .Notes
      
    .Link
    https://trevorsullivan.net
    https://developer.github.com/v3/gists
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