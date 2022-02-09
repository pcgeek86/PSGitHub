$betaProjectItemFragment = Get-Content -Raw "$PSScriptRoot/BetaProjectItemFragment.graphql"

function Add-GitHubBetaProjectItem {
    <#
    .SYNOPSIS
        EXPERIMENTAL: Adds an item to a GitHub project (Beta).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $ProjectNodeId,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('node_id', 'id')]
        [ValidateNotNullOrEmpty()]
        [string] $ContentNodeId,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token
    )

    process {
        $result = Invoke-GitHubGraphQlApi `
            -Headers @{ 'GraphQL-Features' = 'projects_next_graphql' } `
            -Query ('mutation($input: AddProjectNextItemInput!) {
                addProjectNextItem(input: $input) {
                    projectNextItem {
                        ...BetaProjectItemFragment
                    }
                }
            }
            ' + $betaProjectItemFragment) `
            -Variables @{
                input = @{
                    projectId = $ProjectNodeId
                    contentId = $ContentNodeId
                }
            } `
            -BaseUri $BaseUri `
            -Token $Token

        $item = $result.addProjectNextItem.projectNextItem

        Add-Member -InputObject $item -NotePropertyName 'ProjectNodeId' -NotePropertyValue $ProjectNodeId

        $item
    }
}
