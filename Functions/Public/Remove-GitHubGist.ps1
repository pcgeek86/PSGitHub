function Remove-GitHubGist {
    <#
    .Synopsis
    This command deletes a GitHub Gist code snippet.
    
    .Description
    This command is responsible for deleting GitHub Gist code snippets.
    
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