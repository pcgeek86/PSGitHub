function Get-GitHubIssueTimeline {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType('PSGitHub.Event')]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('User')]
        [string] $Owner,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[\w-\.]+$')]
        [Alias('Repository')]
        [string] $RepositoryName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [int] $Number,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token
    )

    process {
        Invoke-GitHubApi "repos/$Owner/$RepositoryName/issues/$Number/timeline" `
            -Accept 'application/vnd.github.mockingbird-preview', 'application/vnd.github.starfox-preview+json' `
            -BaseUri $BaseUri `
            -Token $Token |
            ForEach-Object { $_ } |
            ForEach-Object {
                $_.PSTypeNames.Insert(0, 'PSGitHub.Event')
                if ($_.Actor) {
                    $_.Actor.PSTypeNames.Insert(0, 'PSGitHub.User')
                }
                if ($_.Event -in 'labeled', 'unlabeled') {
                    $_.Label.PSTypeNames.Insert(0, 'PSGitHub.Label')
                }
                if ($_.Event -eq 'cross-referenced') {
                    $_.Source.Issue.PSTypeNames.Insert(0, 'PSGitHub.Issue')
                    if ($_.Source.Issue.pull_request) {
                        $_.Source.Issue.PSTypeNames.Insert(0, 'PSGitHub.PullRequest')
                    }
                }
                $_
            }
    }
}
