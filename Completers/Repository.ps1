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
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    #Add-DefaultParameterValues -Command $commandName -Parameters $fakeBoundParameter
    $RepoArray = [System.Object[]]::new(40)

    $findRepoParams = @{
            Query = $wordToComplete
    }
    if ($fakeBoundParameter.ContainsKey('Owner')) {
        $findRepoParams.Query += ' user:{0}' -f $fakeBoundParameter.Owner
    }
    try {
        Find-GitHubRepository @findRepoParams | ForEach-Object -Begin { $i = 0 } -Process {
            $RepoArray[$i] = $PSItem
            $i++
        }
    }
    catch {
        # Once array is filled up, stop execution
    }

    try {
        foreach ($Repo in $RepoArray) {
            $tooltip = if ($Repo.Description) { $Repo.Description } else { $Repo.Name }
            if (!$fakeBoundParameter.ContainsKey('Owner')) {
                $CompletionText = '{0} -Owner {1}' -f $Repo.Name, $Repo.Owner
                [CompletionResult]::new($CompletionText, $Repo.Name, [CompletionResultType]::ParameterValue, $tooltip)
            }
            else {
                [CompletionResult]::new($Repo.Name, $Repo.Name, [CompletionResultType]::ParameterValue, $tooltip)
            }
        }
    }
    catch {
        # Set-Content -Path $HOME/psgithub.error.log -Value $PSItem
        # Add-Content -Path $HOME/psgithub.error.log -Value ($RepoArray.SyncRoot | ConvertTo-Json)
    }
}

Get-Command *-GitHub* | Where-Object { $_.Parameters -and $_.Parameters.ContainsKey('RepositoryName') } | ForEach-Object {
    Register-ArgumentCompleter -CommandName $_.Name -ParameterName RepositoryName -ScriptBlock $repositoryNameCompleter
}
