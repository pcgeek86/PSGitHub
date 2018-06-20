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

    .PARAMETER Number
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
    New-GitHubComment -Owner Mary -Repository WebApps -Number 42 -Body $body

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Alias('User')]
        [string] $Owner,
        [Parameter(Mandatory = $true)]
        [string] $Repository,
        [Parameter(Mandatory = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $Number,
        [Parameter(Mandatory = $true)]
        [string] $Body,
        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    $uri = 'repos/{0}/{1}/issues/{2}/comments' -f $Owner, $Repository, $Number

    $apiBody = @{
        body = $Body
    } | ConvertTo-Json

    $apiCall = @{
        Method = 'Post';
        Uri    = $uri;
        Body   = $apiBody;
        Token  = $Token
    }

    Invoke-GitHubApi @apiCall
}
