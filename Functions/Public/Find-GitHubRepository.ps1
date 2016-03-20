function Find-GitHubRepository {
    <#
    .Synopsis
    This function searches for repositories on GitHub.
    
    .Parameter SortBy
    Optional. Choose the property to sort on, for GitHub repository search results:
    
      - Default: Best match
      - Stars: Sort by the number of stars the repositories have
      - Forks: Sort by the number of forks the repositories have
      - Updated: Sort by the last update date/time of the repositories
    
    .Parameter SortOrder
    Optional. Specify the order to sort search results.
    
      - Ascending
      - Descending 

    .Link
    https://trevorsullivan.net
    https://developer.github.com/v3/search
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Keywords
      , [Parameter(Mandatory = $false)]
        [ValidateSet('Stars', 'Forks', 'Updated')]
        [string] $SortBy
      , [Parameter(Mandatory = $false)]
        [ValidateSet('Ascending', 'Descending')]
        [string] $SortOrder
    )
    
    ### Create a stub HTTP message body
    $ApiBody = @{ }
    
    ### Add keyword search to message body, if specified by user
    if ($Keywords) { $ApiBody.Add('keywords', $Keywords); }
    
    ### Normalize the "sortby" JSON property, and append to message body
    ### NOTE: The reason we're translating these values (seemingly needlessly), is to provide a first-class PowerShell experience, 
    ###       while maintaining compatibility with the GitHub REST API.
    if ($SortBy) {
        switch ($SortBy) {
            'Stars' { $SortOrder = 'stars'; break; }
            'Forks' { $SortOrder = 'forks'; break; }
            'Updated' { $SortOrder = 'updated'; break; }
            default { break; }
        }
        $ApiBody.Add('sort', $SortBy);
    }
    
    ### Normalize the "sort" JSON property, and append to message body
    if ($SortOrder) {
        switch ($SortOrder) {
            'Ascending' { $SortOrder = 'asc'; break; }
            'Descending' { $SortOrder = 'desc'; break; }
            default { break; }
        }
        $ApiBody.Add('order', $SortOrder);
    }
    
    ### Build the parameters for the REST API call
    $ApiCall = @{
        Body = $ApiBody | ConvertTo-Json;
        RestMethod = 'search/repositories';
        Method = 'Get';
    }
    
    ### Invoke the GitHub REST API
    Invoke-GitHubApi @ApiCall;
}