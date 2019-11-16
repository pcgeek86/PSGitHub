function Merge-GitHubPullRequest {
    <#
    .SYNOPSIS
        This cmdlet merges a pull request
    #>
    [CmdletBinding()]
    param(
        # The owner of the target repository
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Owner = (Get-GitHubUser -Token $Token).login, # This doesn't work for org repos.

        # The name of the target repository
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[\w-\.]+$')]
        [Alias('Repository')]
        [string] $RepositoryName,

        # Number of the pull request
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [int] $Number,

        # SHA that pull request head must match to allow merge.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Sha,

        [AllowEmptyString()]
        [string] $CommitTitle,

        # If you want to keep it empty, pass "`n"
        [AllowEmptyString()]
        [string] $CommitBody,

        # The merge method to use.
        # Defaults to whatever is allowed in the repo, in the order merge, squash, rebase.
        [ValidateSet('merge', 'squash', 'rebase')]
        [string] $MergeMethod,

        # If given, poll the commits status and wait with merging until they pass.
        # Progress is reported through Write-Progress.
        [switch] $WaitForStatusChecks,

        # If given, delete the branch and after merging.
        [switch] $DeleteBranch,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token
    )

    process {
        $apiBody = @{
            sha = $Sha
        }
        if ($CommitTitle) {
            $apiBody.commit_title = $CommitTitle
        }
        if ($CommitBody) {
            $apiBody.commit_body = $CommitBody
        }
        if ($MergeMethod) {
            $apiBody.merge_method = $MergeMethod
        } else {
            $repo = Get-GitHubRepository -Owner $Owner -RepositoryName $RepositoryName -Token $Token
            $apiBody.merge_method = if ($repo.allow_merge_commit) {
                'merge'
            } elseif ($repo.allow_squash_merge) {
                'squash'
            } elseif ($repo.allow_rebase_merge) {
                'rebase'
            }
        }
        if ($WaitForStatusChecks) {
            while ($true) {
                $status = Get-GitHubCombinedCommitStatus -Owner $Owner -RepositoryName $RepositoryName -Ref $Sha -Token $Token
                $success = ($status.Statuses | Where-Object { $_.state -eq 'success' } | Measure-Object).Count
                $total = $status.TotalCount
                Write-Verbose "Commit status: $($status.state)"
                $updates = ($status.Statuses | ForEach-Object {
                    $icon = switch ($_.State) {
                        'success' { "✅" }
                        'pending' { "🔄" }
                        'failure' { "❌" }
                        'error' { "❗️" }
                    }
                    "$icon $($_.Context) $($_.Description)"
                }) -join ", "
                if ($status.state -ne 'pending') {
                    [Console]::Beep()
                    if ($status.state -ne 'success') {
                        Write-Error -Message "Status check $($status.state): $updates"
                        return
                    }
                    break
                }
                if ($ProgressPreference -ne 'SilentlyContinue' -and $total -ne 0) {
                    Write-Progress `
                        -Activity 'Waiting for status checks to pass' `
                        -Status "$success/$($total): $updates" `
                        -PercentComplete (($success / $total) * 100)
                }
                Start-Sleep -Seconds 10
            }
        }
        $res = Invoke-GitHubApi "repos/$Owner/$RepositoryName/pulls/$Number/merge" -Method PUT -Body ($apiBody | ConvertTo-Json) -BaseUri $BaseUri -Token $Token
        $res
        # Only delete the branch if merge was successful
        if ($res -and $res.merged -and $DeleteBranch) {
            $pr = Get-GitHubPullRequest -Owner $Owner -RepositoryName $RepositoryName -Number $Number -Token $Token
            try {
                $pr | Remove-GitHubGitRef -Token $Token
            } catch {
                # Ignore Reference not found errors from the branch being auto-deleted
                # See https://help.github.com/en/articles/managing-the-automatic-deletion-of-branches
                if (
                    $_.Exception.PSObject.TypeNames -notcontains 'Microsoft.PowerShell.Commands.HttpResponseException' -or # PowerShell Core
                    $_.Exception -isnot [System.Net.WebException] -or # Windows PowerShell
                    $_.Exception.Response.StatusCode -ne 422 # Unprocessable Entity
                ) {
                    Write-Error $_
                }
            }
        }
    }
}
