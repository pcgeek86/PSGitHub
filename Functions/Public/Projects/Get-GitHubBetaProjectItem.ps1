$betaProjectItemFragment = Get-Content -Raw "$PSScriptRoot/BetaProjectItemFragment.graphql"

function Get-GitHubBetaProjectItem {
    <#
    .SYNOPSIS
        EXPERIMENTAL: Gets the items in a GitHub project (Beta).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $ProjectNodeId,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token
    )

    process {
        # Paginate in reverse, to get the most recent items first.
        $before = $null
        do {
            Write-Verbose "Requesting previous page (paginating backwards)"
            $result = Invoke-GitHubGraphQlApi `
                -Headers @{ 'GraphQL-Features' = 'projects_next_graphql' } `
                -Query ('query($projectId: ID!, $before: String) {
                    node(id: $projectId) {
                        ... on ProjectNext {
                            items(last: 100, before: $before) {
                                pageInfo {
                                    hasPreviousPage
                                    startCursor
                                }
                                nodes {
                                    ...BetaProjectItemFragment
                                }
                            }
                        }
                    }
                }
                ' + $betaProjectItemFragment) `
                -Variables @{
                    projectId = $ProjectNodeId
                    before = $before
                } `
                -BaseUri $BaseUri `
                -Token $Token

            $nodes = $result.node.items.nodes
            [array]::Reverse($nodes) | Out-Null
            foreach ($node in $nodes) {
                # Expose fields as ergonomic name=>value hashtable
                $fieldHashTable = @{ }
                foreach ($field in $node.fieldValues.nodes) {
                    $fieldHashTable[$field.projectField.name] = $field.value
                }
                Add-Member -InputObject $node -NotePropertyName 'Fields' -NotePropertyValue $fieldHashTable

                $node
            }

            $before = $result.node.items.pageInfo.startCursor
        } while ($result.node.items.pageInfo.hasPreviousPage)
    }
}
