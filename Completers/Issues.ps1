using namespace System.Management.Automation;

$labelCompleter = {
    [CmdletBinding()]
    param([string]$command, [string]$parameter, [string]$wordToComplete, [CommandAst]$commandAst, [Hashtable]$params)
    Add-DefaultParameterValues -Command $command -Parameters $params
    $getLabelParams = @{ }
    if (-not $params.ContainsKey('RepositoryName') -or -not $params.ContainsKey('Owner')) {
        return
    }
    $getLabelParams.Owner = $params.Owner
    $getLabelParams.RepositoryName = $params.RepositoryName
    if ($params.ContainsKey('Token')) {
        $getLabelParams.Token = $params.Token
    }
    Get-GitHubLabel @getLabelParams |
        Where-Object { $_.Name -like "$wordToComplete*" } |
        ForEach-Object {
            $tooltip = if ($_.Description) { $_.Description } else { $_.Name }
            [CompletionResult]::new($_.Name, " " + $_.ToColoredString(), [CompletionResultType]::ParameterValue, $tooltip)
        }
}
Register-ArgumentCompleter -CommandName New-GitHubPullRequest -ParameterName Labels -ScriptBlock $labelCompleter
Register-ArgumentCompleter -CommandName New-GitHubIssue -ParameterName Labels -ScriptBlock $labelCompleter
Register-ArgumentCompleter -CommandName Update-GitHubIssue -ParameterName Labels -ScriptBlock $labelCompleter

$assigneeCompleter = {
    [CmdletBinding()]
    param([string]$command, [string]$parameter, [string]$wordToComplete, [CommandAst]$commandAst, [Hashtable]$params)
    Add-DefaultParameterValues -Command $command -Parameters $params
    $getAssigneeParams = @{ }
    if (-not $params.ContainsKey('RepositoryName') -or -not $params.ContainsKey('Owner')) {
        return
    }
    $getAssigneeParams.Owner = $params.Owner
    $getAssigneeParams.RepositoryName = $params.RepositoryName
    if ($params.ContainsKey('Token')) {
        $getAssigneeParams.Token = $params.Token
    }
    Get-GitHubAssignee @getAssigneeParams |
        Where-Object { $_.Login -like "$wordToComplete*" } |
        ForEach-Object {
            [CompletionResult]::new($_.Login, $_.Login, [CompletionResultType]::ParameterValue, $_.Login)
        }
}
Register-ArgumentCompleter -CommandName New-GitHubPullRequest -ParameterName Assignees -ScriptBlock $assigneeCompleter
Register-ArgumentCompleter -CommandName New-GitHubIssue -ParameterName Assignees -ScriptBlock $assigneeCompleter
Register-ArgumentCompleter -CommandName Update-GitHubIssue -ParameterName Assignees -ScriptBlock $assigneeCompleter

# for both issues and PRs
$issueNumberCompleter = {
    [CmdletBinding()]
    param([string]$command, [string]$parameter, [string]$wordToComplete, [CommandAst]$commandAst, [Hashtable]$params)

    Add-DefaultParameterValues -Command $command -Parameters $params
    $tokenParam = @{ }
    if ($params.ContainsKey('Token')) {
        $tokenParam.Token = $params.Token
    }
    & {
        if ($wordToComplete -match '^\d*$') {
            if (-not $params.ContainsKey('RepositoryName')) {
                return
            }
            $getIssueParams = $tokenParam + @{
                RepositoryName = $params.RepositoryName
                State = 'all'
            }
            if ($params.ContainsKey('Owner')) {
                $getIssueParams.Owner = $params.Owner
            }
            Get-GitHubIssue @getIssueParams | Where-Object { "$($_.Number)" -like "$wordToComplete*" }
        } else {
            $findIssueParams = $tokenParam + @{
                Query = "`"$($params[$parameter])`" in:title"
            }
            if ($params.ContainsKey('RepositoryName')) {
                $findIssueParams.Query += " repo:$($params.Owner)/$($params.RepositoryName)"
            } elseif ($params.ContainsKey('Owner')) {
                $findIssueParams.Query += " user:$($params.Owner)"
            }
            Find-GitHubIssue @findIssueParams
        }
    } |
    Select-Object -First 10 |
    ForEach-Object {
        $color = $_.GetVT100ForegroundColor()
        $number = $_.Number.ToString().PadLeft(5, ' ')
        [CompletionResult]::new($_.Number, "$color$($_.Icon)`e[39m $number `e[3m$($_.Title)`e[23m", [CompletionResultType]::ParameterValue, "#$($_.Number) $($_.Title)")
    }
}
Register-ArgumentCompleter -CommandName Get-GitHubIssue -ParameterName Number -ScriptBlock $issueNumberCompleter
Register-ArgumentCompleter -CommandName New-GitHubPullRequest -ParameterName Issue -ScriptBlock $issueNumberCompleter
Register-ArgumentCompleter -CommandName New-GitHubComment -ParameterName Number -ScriptBlock $issueNumberCompleter
Register-ArgumentCompleter -CommandName Get-GitHubPullRequest -ParameterName Number -ScriptBlock $issueNumberCompleter
Register-ArgumentCompleter -CommandName Merge-GitHubPullRequest -ParameterName Number -ScriptBlock $issueNumberCompleter
Register-ArgumentCompleter -CommandName Update-GitHubIssue -ParameterName Number -ScriptBlock $issueNumberCompleter
Register-ArgumentCompleter -CommandName Get-GitHubComment -ParameterName Number -ScriptBlock $issueNumberCompleter

$issueReferenceCompleter = {
    [CmdletBinding()]
    param([string]$command, [string]$parameter, [string]$wordToComplete, [CommandAst]$commandAst, [Hashtable]$params)
    Add-DefaultParameterValues -Command $command -Parameters $params
    $tokenParam = @{ }
    if ($params.ContainsKey('Token')) {
        $tokenParam.Token = $params.Token
    }
    $match = [regex]::Match($wordToComplete, '(?m)#(\w*)["'']?$')
    if (-not $match.Success) {
        return
    }
    & {
        if ($match.Groups[1] -match '^\d+$') {
            $number = $match.Groups[1]
            if (-not $params.ContainsKey('RepositoryName')) {
                return
            }
            $getIssueParams = $tokenParam + @{
                RepositoryName = $params.RepositoryName
                State = 'all'
            }
            if ($params.ContainsKey('Owner')) {
                $getIssueParams.Owner = $params.Owner
            }
            Get-GitHubIssue @getIssueParams | Where-Object { "$($_.Number)" -like "$number*" }
        } else {
            $term = $match.Groups[1]
            $findIssueParams = $tokenParam + @{
                Query = "`"$term`" in:title"
            }
            if ($params.ContainsKey('RepositoryName')) {
                $findIssueParams.Query += " repo:$($params.Owner)/$($params.RepositoryName)"
            } elseif ($params.ContainsKey('Owner')) {
                $findIssueParams.Query += " user:$($params.Owner)"
            }
            Find-GitHubIssue @findIssueParams
        }
    } |
    Select-Object -First 10 |
    ForEach-Object {
        $color = $_.GetVT100ForegroundColor()
        $number = $_.Number.ToString().PadLeft(5, ' ')
        $insertText = $wordToComplete.Substring(0, $match.Index) + '#' + $_.Number
        [CompletionResult]::new($insertText, "$color$($_.Icon)`e[39m $number `e[3m$($_.Title)`e[23m", [CompletionResultType]::ParameterValue, "#$($_.Number) $($_.Title)")
    }
}
# Register for all Body parameters (where issues can be referenced)
Get-Command *-GitHub* | Where-Object { $_.Parameters -and $_.Parameters.ContainsKey('Body') } | ForEach-Object {
    Register-ArgumentCompleter -CommandName $_.Name -ParameterName Body -ScriptBlock $issueReferenceCompleter
}

