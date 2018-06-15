function New-GitHubPullRequest {
    <#
    .SYNOPSIS
        This cmdlet creates submitts a pull request to a repo

    .DESCRIPTION
        This cmdlet submitts a pull request from branch to an upstream branch,
        you can set the title and body of the pull request (default),
        alternatively you can also creates a pull request based on issue.

    .EXAMPLE
        explaination
        PS C:\> example usage

    .PARAMETER Owner
        Optional.
        the Owner of the upstream repo (the repo that you want to send the pull request to),
        default is the user returned by Get-GitHubAuthenticatedUser

    .PARAMETER Repository
        Mandatory.
        the name of the upstream repo (the repo that you want to send the pull request to)

    .PARAMETER Head
        Mandatory. The name of the branch where your changes are implemented.
        For cross-repository pull requests in the same network, namespace head with a user like this: username:branch

    .PARAMETER Base
        Mandatory. The name of the branch you want the changes pulled into. This should be an existing branch on the current repository.
        You cannot submit a pull request to one repository that requests a merge to a base of another repository.

    .PARAMETER Title
        Mandatory if you want to send the pull request via title and body
        The title of the pull request.

    .PARAMETER Body
        Optional. The contents of the pull request.

    .PARAMETER Issue
        Mandatory if you want to send the pull request via existing issue.
        The issue number in this repository to turn into a Pull Request.

    .EXAMPLE
        # creates a pull request from my 'master' (chantisnake is my user name) to upstream 'master'
        C:\PS> New-GitHubPullRequest -Owner  'test-orgnization' -Repository 'test-repo' -Head 'chantisnake:master' -Base master -Title 'new test pull request' -body 'the awesome content in the pull request'

        # creates a pull request via issue #2
        New-GitHubPullRequest -Owner  'test-orgnization' -Repository 'test-repo' -Head 'chantisnake:master' -Base master -issue 2

    .NOTES
        Please make sure the Head is in the right format.

    #>
    [CmdletBinding(DefaultParameterSetName = 'title')]
    param(
        [Parameter(Mandatory = $False)]
        [string] $Owner = (Get-GitHubAuthenticatedUser).login,
        [Parameter(Mandatory = $true)]
        [string] $Repository,
        [Parameter(Mandatory = $true)]
        [string] $Head,
        [Parameter(Mandatory = $true)]
        [string] $Base,
        [Parameter(Mandatory = $true, ParameterSetName = 'title')]
        [string] $Title,
        [Parameter(Mandatory = $false, ParameterSetName = 'title')]
        [string] $Body,
        [Parameter(Mandatory = $true, ParameterSetName = 'issue')]
        [int] $issue
    )

    begin {
    }

    process {

        # construct the parameter to post
        if ($PSCmdlet.ParameterSetName -eq 'title') {
            # send the pull request via title and body
            $ApiBody = @{
                title = $Title
                head = $Head
                base = $Base
                body = $Body
            } | ConvertTo-Json
        }
        else {
            # send the pull request via existing issue
            $ApiBody = @{
                issue = $issue
                head = $Head
                base = $Base
            } | ConvertTo-Json
        }

        Write-Verbose 'Post parameters are:'
        Write-Verbose $ApiBody

        # construct the parameters of the ApiCall
        $ApiCall = @{
            Body = $ApiBody
            Method = 'post'
            RestMethod = "repos/$Owner/$Repository/pulls"
        }

    }

    end {
        Invoke-GithubApi @ApiCall
    }
}
