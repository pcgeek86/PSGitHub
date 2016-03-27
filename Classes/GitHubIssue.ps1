class GitHubIssue {
    [GitHubRepository] $Repository
    [string] $Title
    [string] $Body
    [string] $Assignee
    [string] $Milestone
}

class GitHubPullRequest : GitHubIssue {
    
}