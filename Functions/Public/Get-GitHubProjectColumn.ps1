function Get-GitHubProjectColumn {
    <#
    .SYNOPSIS
        Gets the columns for a GitHub project.
    #>
    [CmdletBinding()]
    [OutputType('PSGitHub.ProjectColumn')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [int] $ProjectId,

        [int] $ColumnId,

        [string] $Name,

        [Security.SecureString] $Token
    )

    process {
        $url = if ($Id) {
            "/projects/columns/$ColumnId"
        } else {
            "/projects/$ProjectId/columns"
        }
        Invoke-GitHubApi $url -Accept 'application/vnd.github.inertia-preview+json' -Token $Token |
            ForEach-Object { $_ } |
            Where-Object { -not $Name -or $_.Name -like $Name } |
            ForEach-Object {
                $_.PSTypeNames.Insert(0, 'PSGitHub.ProjectColumn')
                $_
            }
    }
}
