function Get-GitHubMilestone {
    <#
    .Synopsis
    Creates a new GitHub issue.

    .Parameter Owner
    The GitHub username of the account or organization that owns the GitHub repository specified in the -Repository parameter.

    .Parameter Repository
    Required. The name of the GitHub repository that is owned by the -Owner parameter, where the new GitHub issue will be
    created.

    .Parameter Milestone
    The number of the milestone that you want to retrieve.

    .Example
    ### Get a specific milestone, based on the milestone's number.
    Get-GitHubMilestone -Milestone 1;

    .Example
    ### Get a list of milestone for the specified repository
    Get-GitHubMilestone -Owner pcgeek86 -Repository PSGitHub;

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
      , [Parameter(ParameterSetName = 'SpecificMilestone', Mandatory = $true)]
        [string] $Milestone
      , [Parameter(ParameterSetName = 'FindMilestones', Mandatory = $false)]
        [ValidateSet('Open', 'Closed', 'All')]
        [string] $State
      , [Parameter(ParameterSetName = 'FindMilestones', Mandatory = $false)]
        [ValidateSet('DueDate', 'Completeness')]
        [string] $Sort
      , [Parameter(ParameterSetName = 'FindMilestones', Mandatory = $false)]
        [ValidateSet('Ascending', 'Descending')]
        [string] $Direction
    )

    ### Build the core message body -- we'll add more properties soon
    $ApiBody = @{
    };

    ### Add the milestone property
    if ($Milestone) { $ApiBody.Add('milestone', $Milestone); }

    ### Normalize the "sort" JSON property
    if ($Sort) {
        switch ($Sort) {
            'DueDate' { $Sort = 'due_on'; break; }
            'Completeness' { $Sort = 'completeness'; break; }
            default { break; }
        }
        $ApiBody.Add('sort', $Sort);
    }

    ### Normalize the "state" JSON property
    if ($State) {
        switch ($State) {
            'Open' {
                $State = 'open'; break; }
            'Closed' {
                $State = 'closed'; break; }
            'All' {
                $State = 'all'; break; }
            default {
                break; }
        }
        $ApiBody.Add('state', $State);
    }

    ### Normalize the "direction" JSON property
    if ($Direction) {
        switch ($Direction) {
            'Ascending' {
                $Direction = 'asc'; break; }
            'Descending' {
                $Direction = 'desc'; break; }
            default {
                break; }
        }
        $ApiBody.Add('direction', $Direction);
    }

    ### Determine the appropriate REST method to use
    if ($Milestone) {
        $RestMethod = '/repos/{0}/{1}/milestones/{2}' -f $Owner, $Repository, $Milestone; }
    else {
        $RestMethod = '/repos/{0}/{1}/milestones' -f $Owner, $Repository; }

    ### Set up the API call
    $ApiCall = @{
        Body = $ApiBody | ConvertTo-Json
        RestMethod = $RestMethod;
        Method = 'Get';
    }

    ### Invoke the GitHub REST method
    Invoke-GitHubApi @ApiCall;
}
