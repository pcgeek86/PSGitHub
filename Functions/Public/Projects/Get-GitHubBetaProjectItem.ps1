$betaProjectItemFragment = Get-Content -Raw "$PSScriptRoot/BetaProjectItemFragment.graphql"

function Get-GitHubBetaProjectItem {
    <#
    .SYNOPSIS
        EXPERIMENTAL: Gets the items in a GitHub project (Beta).
    #>
    [CmdletBinding()]
    param(
        # The node ID of a GitHub Beta project, an issue or a pull request.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('node_id', 'id')]
        [ValidateNotNullOrEmpty()]
        [string] $NodeId,

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
                -Query ('query($nodeId: ID!, $before: String) {
                    node(id: $nodeId) {
                        __typename
                        ... on ProjectNext {
                            items(last: 100, before: $before) {
                                ...ConnectionFields
                            }
                        }
                        ... on Issue {
                            items: projectNextItems(last: 10, before: $before) {
                                ...ConnectionFields
                            }
                        }
                        ... on PullRequest {
                            items: projectNextItems(last: 10, before: $before) {
                                ...ConnectionFields
                            }
                        }
                    }
                }
                fragment ConnectionFields on ProjectNextItemConnection {
                    pageInfo {
                        hasPreviousPage
                        startCursor
                    }
                    nodes {
                        ...BetaProjectItemFragment
                    }
                }
                ' + $betaProjectItemFragment) `
                -Variables @{
                    nodeId = $NodeId
                    before = $before
                } `
                -BaseUri $BaseUri `
                -Token $Token

            if ($result.node.__typename -notin 'ProjectNext', 'Issue', 'PullRequest') {
                throw "Node ID must be a ProjectNext, Issue or PullRequest, was $($result.node.__typename). Node ID: $NodeId"
            }
            $nodes = $result.node.items.nodes
            [array]::Reverse($nodes) | Out-Null
            foreach ($node in $nodes) {
                # Expose fields as ergonomic name=>value hashtable
                $fieldHashTable = [ordered]@{ }
                foreach ($fieldValue in $node.fieldValues.nodes) {
                    $fieldValue.projectField.settings = $fieldValue.projectField.settings | ConvertFrom-Json
                    $fieldSettings = $fieldValue.projectField.settings
                    $value = if ($fieldSettings -and $fieldSettings.PSObject.Properties['options']) {
                        ($fieldSettings.options | Where-Object { $_.id -eq $fieldValue.value }).Name
                    } else {
                        $fieldValue.value
                    }
                    $fieldHashTable[$fieldValue.projectField.name] = $value
                }
                Add-Member -InputObject $node -NotePropertyName 'Fields' -NotePropertyValue $fieldHashTable

                if ($node.content) {
                    $node.content.labels = $node.content.labels.nodes
                    $node.content.assignees = $node.content.assignees.nodes
                }

                # Allow easier piping to other commands
                Add-Member -InputObject $node -NotePropertyName 'ProjectNodeId' -NotePropertyValue $node.project.id

                $node
            }

            $before = $result.node.items.pageInfo.startCursor
        } while ($result.node.items.pageInfo.hasPreviousPage)
    }
}
