function New-GitHubProjectCard {
    <#
    .SYNOPSIS
        Creates a new GitHub project card.
    .INPUTS
        PSGitHub.Issue. You can pipe in an issue from e.g. Get-GitHubIssue.
        PSGitHub.PullRequest. You can pipe in an issue from e.g. Get-GitHubPullRequest.
        PSGitHub.ProjectColumn. You can pipe in a column from Get-GitHubProjectColumn.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType('PSGitHub.ProjectCard')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [int] $ColumnId,

        # Creates a simple card with a note.
        [Parameter(Mandatory, ParameterSetName = 'Note')]
        [string] $Note,

        # Creates a card for an issue or pull request.
        [Parameter(Mandatory, ParameterSetName = 'ContentType', ValueFromPipelineByPropertyName)]
        [ValidateSet('Issue', 'PullRequest')]
        [Alias('Type')]
        [string] $ContentType,

        # The ID of the issue or pull request to create the card for.
        [Parameter(Mandatory, ParameterSetName = 'ContentType', ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [int] $ContentId,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token
    )

    process {
        $body = switch ($PSCmdlet.ParameterSetName) {
            'Note' {
                @{
                    note = $Note
                }
            }
            'ContentType' {
                @{
                    content_type = $ContentType
                    content_id = $ContentId
                }
            }
        }
        $headers = @{
            Accept = 'application/vnd.github.inertia-preview+json'
        }

        $shouldProcessCaption = "Creating new GitHub project card"
        $shouldProcessDescription = "Creating new GitHub project card in column $ColumnId"
        $shouldProcessWarning = "Do you want to create a new GitHub project card in column $ColumnId?"

        if ($PSCmdlet.ShouldProcess($shouldProcessDescription, $shouldProcessWarning, $shouldProcessCaption)) {
            Invoke-GitHubApi -Method POST "projects/columns/$ColumnId/cards" -Headers $headers -Body ($body | ConvertTo-Json) -BaseUri $BaseUri -Token $Token |
                ForEach-Object {
                    $_.PSTypeNames.Insert(0, 'PSGitHub.ProjectCard')
                    $_.Creator.PSTypeNames.Insert(0, 'PSGitHub.User')
                    $_
                }
        }
    }
}
