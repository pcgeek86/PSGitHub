function Move-GitHubProjectCard {
    <#
    .SYNOPSIS
        Moves a GitHub project card inside and in between columns.
    #>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Top')]
    param(
        # The ID of the card to move
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [int] $CardId,

        # Move the card to the top of the column
        [Parameter(Mandatory, ParameterSetName = 'top')]
        [switch] $Top,

        # Move the card to the bottom of the column
        [Parameter(Mandatory, ParameterSetName = 'bottom')]
        [switch] $Bottom,

        # ID of a card to place the card after
        [Parameter(Mandatory, ParameterSetName = 'after')]
        [int] $After,

        # Optional: Column to move the card to
        [int] $ColumnId,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token
    )

    process {
        $body = @{
            position = switch ($PSCmdlet.ParameterSetName) {
                'Top' { 'top' }
                'Bottom' { 'bottom' }
                'After' { "after:$After" }
            }
        }
        if ($ColumnId) {
            $body.column_id = $ColumnId
        }

        if ($Top -or $Bottom) {
            $position = "to the $($PSCmdlet.ParameterSetName)"
            if ($ColumnId) {
                $position += " of column $ColumnId"
            }
        } else {
            $position = "after card $After"
            if ($ColumnId) {
                $position = "to column $ColumnId $position"
            }
        }

        $shouldProcessCaption = "Moving GitHub project card"
        $shouldProcessDescription = "Moving GitHub project card $CardId $position"
        $shouldProcessWarning = "Do you want to move GitHub project card $CardId $position?"

        if ($PSCmdlet.ShouldProcess($shouldProcessDescription, $shouldProcessWarning, $shouldProcessCaption)) {
            Invoke-GitHubApi -Method POST "projects/columns/cards/$CardId/moves" -Accept 'application/vnd.github.inertia-preview+json' -Body ($body | ConvertTo-Json) -BaseUri $BaseUri -Token $Token | Out-Null
            Write-Information "Moved GitHub project card $CardId $position"
        }
    }
}
