function Test-GitHubAssignee {
    <#
    .Synopsis
    This function returns a boolean value, indicating whether or not a GitHub username is a valid assignee for the specified repository.
    
    .Link
    https://trevorsullivan.net
    https://developer.github.com/v3/issues/assignees/#check-assignee
    #>
    [CmdletBinding()]
    param ()
    
    $ApiCall = @{
        Body = '';
        RestMethod = '';
        Method = '';
    }
    
    Invoke-GitHubApi @ApiCall;
}