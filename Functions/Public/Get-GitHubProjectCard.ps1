function Get-GitHubProjectCard {
    <#
    .SYNOPSIS
        Gets the cards for a column of a GitHub project.
    #>
    [CmdletBinding()]
    [OutputType('PSGitHub.ProjectCard')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [int] $ColumnId,

        [Parameter(ValueFromPipelineByPropertyName)]
        [int] $CardId,

        [Security.SecureString] $Token
    )

    process {
        $url = if ($CardId) {
            "/projects/columns/cards/$CardId"
        } else {
            "/projects/columns/$ColumnId/cards"
        }
        Invoke-GitHubApi $url -Accept 'application/vnd.github.inertia-preview+json' -Token $Token |
            ForEach-Object { $_ } |
            ForEach-Object {
                $_.PSTypeNames.Insert(0, 'PSGitHub.ProjectCard')
                $_
            }
    }
}
