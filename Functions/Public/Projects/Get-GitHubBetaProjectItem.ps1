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
        $project = Get-GitHubBetaProject -Id $ProjectNodeId -Token $Token -BaseUri $BaseUri
        if (!$project) {
            return
        }

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
                $fieldHashTable = [ordered]@{ }
                foreach ($field in $node.fieldValues.nodes) {
                    $fieldSettings = $project.fields[$field.projectField.name].settings
                    $value = if ($fieldSettings -and $fieldSettings.PSObject.Properties['options']) {
                        ($fieldSettings.options | Where-Object { $_.id -eq $field.value }).Name
                    } else {
                        $field.value
                    }
                    $fieldHashTable[$field.projectField.name] = $value
                }
                Add-Member -InputObject $node -NotePropertyName 'Fields' -NotePropertyValue $fieldHashTable

                if ($node.content) {
                    $node.content.labels = $node.content.labels.nodes
                }

                $node
            }

            $before = $result.node.items.pageInfo.startCursor
        } while ($result.node.items.pageInfo.hasPreviousPage)
    }
}
