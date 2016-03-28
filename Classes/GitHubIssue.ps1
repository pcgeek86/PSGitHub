class GitHubRepository {
    [string] $Name
    [string] $Description
    [bool] $IsPrivate
    
       
}

class GitHubIssue {
    ### The GitHub repository that the issue belongs to
    [GitHubRepository] $Repository
    [string] $Title
    [string] $Body
    [string] $Assignee
    [string] $Milestone
}

### In the GitHub object mode, a Pull Request "is an" issue, but not vice versa
class GitHubPullRequest : GitHubIssue {
    
}