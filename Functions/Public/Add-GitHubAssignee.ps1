function Add-GitHubAssignee {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType('PSGitHub.Issue')]
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

        # Usernames who will be added as assignees to the issue.
        [string[]] $Assignees,

        # Team slugs whose members will be added as assignees to the issue (in addition to Assignees).
        [string[]] $TeamAssignees,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token
    )

    process {
        if ($TeamAssignees) {
            $Assignees += $TeamAssignees |
                ForEach-Object { Get-GitHubTeam -OrganizationName $Owner -Slug $_ -Token $Token } |
                Get-GitHubTeamMember -Token $Token |
                ForEach-Object { $_.Login }
        }

        $body = @{
            assignees = $Assignees
        }

        $shouldProcessCaption = "Adding assignee to GitHub issue"
        $shouldProcessDescription = "Adding $($Assignees.Count) assignees to GitHub issue `e[1m#$Number`e[0m in repository `e[1m$Owner/$RepositoryName`e[0m."
        $shouldProcessWarning = "Do you want to add $($Assignees.Count) assignees the GitHub issue `e[1m#$Number`e[0m in repository `e[1m$Owner/$RepositoryName`e[0m?"

        if ($PSCmdlet.ShouldProcess($shouldProcessDescription, $shouldProcessWarning, $shouldProcessCaption)) {
            Invoke-GitHubApi -Method POST "repos/$Owner/$RepositoryName/issues/$Number/assignees" -Body ($body | ConvertTo-Json) -BaseUri $BaseUri -Token $Token |
                ForEach-Object {
                    $_.PSTypeNames.Insert(0, 'PSGitHub.Issue')
                    $_.User.PSTypeNames.Insert(0, 'PSGitHub.User')
                    foreach ($label in $_.Labels) {
                        $label.PSTypeNames.Insert(0, 'PSGitHub.Label')
                    }
                    foreach ($assignee in $_.Assignees) {
                        $assignee.PSTypeNames.Insert(0, 'PSGitHub.User')
                    }
                    $_
                }
        }
    }
}
