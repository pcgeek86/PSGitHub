using namespace System.Management.Automation;

$issueSearchCompleter = {
    [CmdletBinding()]
    param([string]$command, [string]$parameter, [string]$wordToComplete, [CommandAst]$commandAst, [Hashtable]$params)
    Add-DefaultParameterValues -Command $command -Parameters $params

    $tokenParam = @{ }
    if ($params.ContainsKey('Token')) {
        $tokenParam.Token = $params.Token
    }

    $keywords = @{
        'type' = 'github commenter:defunkt type:issue matches issues that contain the word "github," and have a comment by @defunkt.'
        'is' = 'code of conduct is:unlocked is:issue archived:false matches issues or pull requests with the words "code of conduct" that have an unlocked conversation in a repository that is not archived.'
        'in' = 'shipit in:comments matches issues mentioning "shipit" in their comments.'
        'user' = 'user:defunkt ubuntu matches issues with the word "ubuntu" from repositories owned by @defunkt.'
        'org' = 'org:github matches issues in repositories owned by the GitHub organization.'
        'repo' = 'repo:mozilla/shumway created:<2012-03-01 matches issues from @mozilla''s shumway project that were created before March 2012.'
        'state' = 'design state:closed in:body matches closed issues with the word "design" in the body.'
        'author' = 'author:app/robot matches issues created by the integration account named "robot."'
        'assignee' = 'assignee:vmg repo:libgit2/libgit2 matches issues and pull requests in libgit2''s project libgit2 that are assigned to @vmg.'
        'mentions' = 'resque mentions:defunkt matches issues with the word "resque" that mention @defunkt.'
        'team' = 'team:jekyll/owners matches issues where the @jekyll/owners team is mentioned.'
        'commenter' = 'github commenter:defunkt org:github matches issues in repositories owned by GitHub, that contain the word "github," and have a comment by @defunkt.'
        'involves' = 'involves:defunkt involves:jlord matches issues either @defunkt or @jlord are involved in.'
        'label' = 'label:"help wanted" language:ruby matches issues with the label "help wanted" that are in Ruby repositories.'
        'milestone' = 'milestone:"overhaul" matches issues that are in a milestone named "overhaul."'
        'project' = 'project:github/linguist/1 matches issues that are associated with project board 1 in @github''s linguist repository.'
        'status' = 'created:2015-05-01..2015-05-30 status:failure matches pull requests opened on May 2015 with a failed status.'
        'head' = 'head:change is:closed is:unmerged matches pull requests opened from branch names containing the word "change" that are closed.'
        'base' = 'base:gh-pages matches pull requests that are being merged into the gh-pages branch.'
        'language' = 'language:ruby state:open matches open issues that are in Ruby repositories.'
        'comments' = 'state:closed comments:>100 matches closed issues with more than 100 comments.'
        'review' = 'type:pr review:changes_requested matches pull requests in which a reviewer has asked for changes.'
        'reviewed-by' = 'type:pr reviewed-by:gjtorikian matches pull requests reviewed by a particular person.'
        'review-requested' = 'type:pr review-requested:benbalter matches pull requests where a specific person is requested for review. Requested reviewers are no longer listed in the search results after they review a pull request. If the requested person is on a team that is requested for review, then review requests for that team will also appear in the search results.'
        'team-review-requested' = 'type:pr review-requested:atom/design matches pull requests that have review requests from the team atom/design. Requested reviewers are no longer listed in the search results after they review a pull request.'
        'created' = 'language:c# created:<2011-01-01 state:open matches open issues that were created before 2011 in repositories written in C#.'
        'updated' = 'weird in:body updated:>=2013-02-01 matches issues with the word "weird" in the body that were updated after February 2013.'
        'closed' = 'language:swift closed:>2014-06-11 matches issues and pull requests in Swift that were closed after June 11, 2014.'
        'merged' = 'language:javascript merged:<2011-01-01 matches pull requests in JavaScript repositories that were merged before 2011.'
        'archived' = 'archived:false GNOME matches issues and pull requests that contain the word "GNOME" in unarchived repositories you have access to.'
        'no' = 'build no:project matches issues not associated with a project board, containing the word "build."'
    }

    $match = [regex]::Match($wordToComplete, '([^\s-''":]+)(:[^\s:''"]*)?[''"]?$') # TODO support quoted values
    if (-not $match.Success) {
        Write-Warning "Didn't match regex: $wordToComplete"
        return
    }
    $keyword = $match.Groups[1]
    if (-not "$($match.Groups[2])") {
        # complete keyword
        $keywords.GetEnumerator() |
            Where-Object { $_.Key -like "$keyword*" } |
            ForEach-Object {
                $insertText = $wordToComplete.Substring(0, $match.Index) + $_.Key + ':'
                [CompletionResult]::new($insertText, $_.Key, [CompletionResultType]::ParameterValue, $_.Value)
            }
    } else {
        $value = "$($match.Groups[2])".TrimStart(':')
        # complete values for specific keywords
        & {
            switch ($keyword) {
                'type' { 'issue', 'pr' }
                'is' { 'unlocked', 'issue', 'pr', 'closed', 'open', 'merged', 'unmerged' }
                'state' { 'closed', 'open', 'merged', 'unmerged' }
                'archived' { 'true', 'false' }
                'in' { 'body', 'title', 'comments' }
                'status' { 'pending', 'success', 'failure' }
                'org' { Find-GitHubUser -Query $value @tokenParam | ForEach-Object Login }
                'author' { Find-GitHubUser -Query $value @tokenParam | ForEach-Object Login }
                'review-requested' { Find-GitHubUser -Query $value @tokenParam | ForEach-Object Login }
                'reviewed-by' { Find-GitHubUser -Query $value @tokenParam | ForEach-Object Login }
                'review' { 'none', 'required', 'approved', 'changes_requested' }
                'assignee' { Find-GitHubUser -Query $value @tokenParam | ForEach-Object Login }
                'mentions' { Find-GitHubUser -Query $value @tokenParam | ForEach-Object Login }
                'involves' { Find-GitHubUser -Query $value @tokenParam | ForEach-Object Login }
                'commenter' { Find-GitHubUser -Query $value @tokenParam | ForEach-Object Login }
                'repo' {
                    $query = if ($value.Contains('/')) {
                        $org, $repo = $value -split '/'
                        "org:$org $repo"
                    } else {
                        $value
                    }
                    Find-GitHubRepository -Query $query @tokenParam | ForEach-Object FullName
                }
            }
        } |
            Where-Object { $_ -like "$value*" } |
            ForEach-Object {
                $insertText = $wordToComplete.Substring(0, $match.Index) + $keyword + ':' + $_
                [CompletionResult]::new($insertText, $_, [CompletionResultType]::ParameterValue, $_)
            }
    }
}
Register-ArgumentCompleter -CommandName Find-GitHubIssue -ParameterName Query -ScriptBlock $issueSearchCompleter
