function New-GitHubFork {
    <#
    .SYNOPSIS
        the cmdlet to create a fork

    .DESCRIPTION
        this cmdlet creates a fork of a other's repo in your account, or an organization that you have access to

    .PARAMETER Owner
        the owner of the repo that you want to fork, mandatory

    .PARAMETER Repository
        the name of the repo that you want to fork, mandatory

    .PARAMETER Organization
        the organization you want to fork the upstream repository to, optional
        leave this blank if you want to fork to your account

    .EXAMPLE
        fork the repo 'pcgeek86/PSGitHub' to my 'test-orgnization'
        PS C:\> New-GitHubFork -Owner pcgeek86 -Repository PSGitHub -Organization test-orgnization -verbose

        fork the repo 'pcgeek86/PSGitHub' to my account 
        PS C:\> New-GitHubFork -Owner pcgeek86 -Repository PSGitHub

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Owner,
        [Parameter(Mandatory = $true)]
        [string] $Repository,
        [Parameter(Mandatory = $False)]
        [string] $Organization
    )
    
    begin {
    }
    
    process {
        # construct the post body
        if ($organization) {
            $Body = @{
                organization = $organization
            } | ConvertTo-Json
        }
        else {
            $Body = ""  # nothing in the parameter
        }

        # construct the api call
        $apiCall = @{
            Body = $Body
            Method = 'post'
            RestMethod = "repos/$Owner/$Repository/forks"
        }
    }
    
    end {
        # invoke the api call
        Invoke-GithubApi @apiCall
    }
}