function Get-GitHubCombinedCommitStatus {
    <#
    .SYNOPSIS
        Gets the status of a commit
    #>
    [CmdletBinding()]
    [OutputType('PSGitHub.CombinedCommitStatus')]
    param(
        # The owner of the target repository
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Owner = (Get-GitHubUser -Token $Token).login, # This doesn't work for org repos.

        # The name of the repository
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[\w-\.]+$')]
        [Alias('Repository')]
        [string] $RepositoryName,

        # SHA, branch name or tag name
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias('Sha')]
        [Alias('FriendlyName')]
        [string] $Ref,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token
    )

    process {
        Invoke-GitHubApi "repos/$Owner/$RepositoryName/commits/$Ref/status" -BaseUri $BaseUri -Token $Token | ForEach-Object {
            $_.PSTypeNames.Insert(0, 'PSGitHub.CombinedCommitStatus')
            $_.Repository.PSTypeNames.Insert(0, 'PSGitHub.Repository')
            $_.Repository.Owner.PSTypeNames.Insert(0, 'PSGitHub.User')
            foreach ($status in $_.Statuses) {
                $status.PSTypeNames.Insert(0, 'PSGitHub.CommitStatus')
            }
            $_
        }
    }
}
