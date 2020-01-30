using namespace System.Management.Automation;

$ownerCompleter = {
    [CmdletBinding()]
    param([string]$command, [string]$parameter, [string]$wordToComplete, [CommandAst]$commandAst, [Hashtable]$params)
    Add-DefaultParameterValues -Command $command -Parameters $params
    & {
        $tokenParam = @{ }
        if ($params.ContainsKey('Token')) {
            $tokenParam.Token = $params.Token
        }
        # Requesting one of your own repos
        $user = Get-GitHubUser @tokenParam
        if ($wordToComplete -and $user.Login -like "$wordToComplete*") {
            return $user
        }
        # Requesting a repo of one of your orgs
        $orgs = $user | Get-GitHubOrganization @tokenParam | Where-Object { $_.Login -like "$wordToComplete*" }
        if ($wordToComplete -and $orgs) {
            return $orgs
        }
        # Invoking autocomplete without any character typed
        if (-not $wordToComplete) {
            return ($user, $orgs) | ForEach-Object { $_ }
        }
        # Requesting any other repo
        Find-GitHubUser -Query "in:login $wordToComplete" @tokenParam |
            Where-Object { $_.Login -like "$wordToComplete*" } |
            Select-Object -First 10
    } | ForEach-Object {
        $tooltip = if ('PSGitHub.Organization' -in $_.PSTypeNames -and $_.Description) {
            $_.Description
        } elseif ('PSGitHub.User' -in $_.PSTypeNames -and $_.Name) {
            $_.Name
        } else {
            $_.Login
        }
        [CompletionResult]::new($_.Login, $_.Login, [CompletionResultType]::ParameterValue, $tooltip)
    }
}
Get-Command *-GitHub* | Where-Object { $_.Parameters -and $_.Parameters.ContainsKey('Owner') } | ForEach-Object {
    Register-ArgumentCompleter -CommandName $_.Name -ParameterName Owner -ScriptBlock $ownerCompleter
}

$repositoryNameCompleter = {
    [CmdletBinding()]
    param([string]$command, [string]$parameter, [string]$wordToComplete, [CommandAst]$commandAst, [Hashtable]$params)
    Add-DefaultParameterValues -Command $command -Parameters $params
    $findRepoParams = @{
        Query = $wordToComplete
    }
    if ($params.ContainsKey('Token')) {
        $findRepoParams.Token = $params.Token
    }
    if ($params.ContainsKey('Owner')) {
        $findRepoParams.Query += " user:$($params.Owner)"
    }
    Find-GitHubRepository @findRepoParams |
        Where-Object { $_.Name -like "$wordToComplete*" } |
        Select-Object -First 5 |
        ForEach-Object {
            $tooltip = if ($_.Description) { $_.Description } else { $_.Name }
            [CompletionResult]::new($_.Name, $_.Name, [CompletionResultType]::ParameterValue, $tooltip)
        }
}
Get-Command *-GitHub* | Where-Object { $_.Parameters -and $_.Parameters.ContainsKey('RepositoryName') } | ForEach-Object {
    Register-ArgumentCompleter -CommandName $_.Name -ParameterName RepositoryName -ScriptBlock $repositoryNameCompleter
}
