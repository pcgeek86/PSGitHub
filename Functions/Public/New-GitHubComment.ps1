function New-GitHubComment {
    <#
    .SYNOPSIS
    Creates a comment on a GitHub issue.

    .PARAMETER Owner
    The GitHub username of the account or organization that owns the GitHub repository
    specified in the -Repository parameter.

    .PARAMETER Repository
    The name of the GitHub repository containing the issue to which the comment
    will be added.

    .PARAMETER IssueNumber
    The number of the issue to which the comment will be added.

    .PARAMETER Body
    The text of the comment.

    .EXAMPLE
    # Add a multiline comment containing Markdown to an issue:

    $body = @"
    Things to consider:
    - A thing
    - Another thing
    "@
    New-GitHubComment -Owner Mary -Repository WebApps -IssueNumber 42 -Body $body

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Alias('User')]
        [string] $Owner
      , [Parameter(Mandatory = $true)]
        [string] $Repository
      , [Parameter(Mandatory = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $IssueNumber
      , [Parameter(Mandatory = $true)]
        [string] $Body
    )

    $restMethod = 'repos/{0}/{1}/issues/{2}/comments' -f $Owner, $Repository, $IssueNumber

    # This function's -Body parameter contains the text of the comment. But the
    # -Body parameter to Invoke-GitHubApi is a JSON object. In this case, that
    # object has a "body" property, which is a JSON-escaped string. So:
    $requestBody = @"
{
    "body": $(ConvertTo-Json $Body)
}
"@

    $apiCall = @{
        Method = 'Post';
        RestMethod = $restMethod;
        Body = $requestBody;
    }

    Invoke-GitHubApi @apiCall
}