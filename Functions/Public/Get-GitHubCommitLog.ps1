function Get-GitHubCommitLog {
    <#
    .SYNOPSIS
        Get the commits of a GitHub repository.
    #>

    [CmdletBinding()]
    [OutputType('PSGitHub.Commit')]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Owner,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[\w-\.]+$')]
        [string] $RepositoryName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Name')] # For piping branches
        [string] $Ref,

        [string] $Author,
        [string] $Path,
        [DateTime] $Since,
        [DateTime] $Until,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token
    )

    process {
        $uri = "repos/$Owner/$RepositoryName/commits"
        $params = @()
        if ($Ref) {
            $params += "sha=$Ref"
        }
        if ($Author) {
            $params += "author=$Author"
        }
        if ($Since) {
            $params += "since=" + $Since.ToString('o')
        }
        if ($Until) {
            $params += "until=" + $Until.ToString('o')
        }
        if ($Path) {
            $params += "path=" + $Path.ToString('o')
        }
        $uri += "?" + ($params -join "&")
        # expand arrays
        Invoke-GitHubApi $uri -BaseUri $BaseUri -Token $Token |
            ForEach-Object { $_ } |
            ForEach-Object {
                $_.PSTypeNames.Insert(0, 'PSGitHub.Commit')
                $_.PSTypeNames.Insert(0, 'PSGitHub.GitCommit')
                $_.Author.PSTypeNames.Insert(0, 'PSGitHub.User')
                $_.Committer.PSTypeNames.Insert(0, 'PSGitHub.User')
                foreach ($parent in $_.Parents) {
                    $parent.PSTypeNames.Insert(0, 'PSGitHub.Commit')
                }
                $_
            }
    }
}
