function New-GitHubIssue {
    <#
    .Synopsis
    Creates a new GitHub issue.
    
    .Parameter Title
    Required. The title of the new GitHub issue that will be created. This field doesn't support Markdown.
    
    .Parameter Body
    Optional. Defines the body text, using Markdown, for the GitHub issue. Most people probably won't like you
    if you don't specify a body, so the recommendation would be to specify one.
    
    .Parameter Owner
    The GitHub username of the account or organization that owns the GitHub repository specified in the -Repository parameter.

    .Parameter Repository
    Required. The name of the GitHub repository that is owned by the -Owner parameter, where the new GitHub issue will be
    created.

    .Parameter Assignee
    Optional. The GitHub username of the individual who the new issues will be assigned to.
    
    .Parameter Labels
    Optional. An array of strings that indicate the labels that will be assigned to this GitHub issue upon creation.
    
    .Parameter Milestone
    The number of the milestone that the issue will be assigned to. Use Get-GitHubMilestone to retrieve a list of milestones. 
    
    .Link
    https://trevorsullivan.net
    https://developer.github.com/v3/issues    
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Alias('User')]
        [string] $Owner
      , [Parameter(Mandatory = $true)]
        [string] $Repository
      , [Parameter(Mandatory = $true)]
        [string] $Title
      , [Parameter(Mandatory = $false)]
        [string] $Body
      , [Parameter(Mandatory = $false)]
        [string] $Assignee
      , [Parameter(Mandatory = $false)]
        [string[]] $Labels
      , [Parameter(Mandatory = $false)]
        [string] $Milestone
    )
    
    ### Build the core message body -- we'll add more properties soon
    $ApiBody = @{
        title = $Title;
    };
    
    ### Add an issue body to the message payload (optional)
    if ($Body) { $ApiBody.Add('body', $Body); }

    ### TODO: Validate that this assignee is valid for this specific repository, before attempting to assign them.
    ###       Use the Test-GitHubAssignee command for this. 
    if ($Assignee) { $ApiBody.Add('assignee', $Assignee); }
    
    ### Add array of labels to the issue message body
    if ($Labels) { $ApiBody.Add('labels', $Labels); }

    ### Add the milestone to the issue message body    
    if ($Milestone) { $ApiBody.Add('milestone', $Milestone); }

    ### Set up the API call
    $ApiCall = @{
        Body = $ApiBody | ConvertTo-Json
        RestMethod = 'repos/{0}/{1}/issues' -f $Owner, $Repository;
        Method = 'Post';
    }
    
    ### Invoke the GitHub REST method
    Invoke-GitHubApi @ApiCall;
}