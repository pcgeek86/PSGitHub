using namespace System.Management.Automation;

$milestoneNumberCompleter = {
    [CmdletBinding()]
    param([string]$command, [string]$parameter, [string]$wordToComplete, [CommandAst]$commandAst, [Hashtable]$params)
    Add-DefaultParameterValues -Command $command -Parameters $params
    if (-not $params.ContainsKey('RepositoryName')) {
        return
    }
    $getMilestoneParams = @{
        RepositoryName = $params.RepositoryName
    }
    if ($params.ContainsKey('Owner')) {
        $getMilestoneParams.Owner = $params.Owner
    }
    if ($params.ContainsKey('Token')) {
        $getMilestoneParams.Token = $params.Token
    }
    Get-GitHubMilestone @getMilestoneParams |
        Where-Object { "$($_.Number)" -like "$wordToComplete*" } |
        ForEach-Object {
            $tooltip = $_.Title + "`e[3m" + (if ($_.Description) { $_.Description } else { '' }) + "`e[0m"
            [CompletionResult]::new($_.Number, "$($_.Number.ToString().PadLeft(2, ' ')) `e[3m$($_.Title)`e[0m", [CompletionResultType]::ParameterValue, $tooltip)
        }
}
Register-ArgumentCompleter -CommandName Get-GitHubIssue -ParameterName MilestoneNumber -ScriptBlock $milestoneNumberCompleter
Register-ArgumentCompleter -CommandName New-GitHubPullRequest -ParameterName MilestoneNumber -ScriptBlock $milestoneNumberCompleter
Register-ArgumentCompleter -CommandName Get-GitHubMilestone -ParameterName Number -ScriptBlock $milestoneNumberCompleter

$milestoneTitleCompleter = {
    [CmdletBinding()]
    param([string]$command, [string]$parameter, [string]$wordToComplete, [CommandAst]$commandAst, [Hashtable]$params)
    Add-DefaultParameterValues -Command $command -Parameters $params
    if (-not $params.ContainsKey('RepositoryName')) {
        return
    }
    $getMilestoneParams = @{
        RepositoryName = $params.RepositoryName
    }
    if ($params.ContainsKey('Owner')) {
        $getMilestoneParams.Owner = $params.Owner
    }
    if ($params.ContainsKey('Token')) {
        $getMilestoneParams.Token = $params.Token
    }
    Get-GitHubMilestone @getMilestoneParams |
        Where-Object { $_.Title -like "$wordToComplete*" } |
        ForEach-Object {
            $tooltip = if ($_.Description) { $_.Description } else { $_.Title }
            [CompletionResult]::new($_.Title, $_.Title, [CompletionResultType]::ParameterValue, $tooltip)
        }
}
Register-ArgumentCompleter -CommandName Get-GitHubIssue -ParameterName MilestoneTitle -ScriptBlock $milestoneTitleCompleter
Register-ArgumentCompleter -CommandName New-GitHubPullRequest -ParameterName MilestoneTitle -ScriptBlock $milestoneTitleCompleter
