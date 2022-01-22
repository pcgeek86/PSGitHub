function Get-GitHubBetaProject {
    <#
    .SYNOPSIS
        EXPERIMENTAL: Gets a GitHub project (Beta).
    #>
    [CmdletBinding()]
    param(
        # The project node ID.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('ProjectNodeId')]
        [string] $Id,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token
    )

    process {
        $result = Invoke-GitHubGraphQlApi `
            -Headers @{ 'GraphQL-Features' = 'projects_next_graphql' } `
            -Query 'query($projectId: ID!) {
                node(id: $projectId) {
                    ... on ProjectNext {
                        id
                        number
                        title
                        description
                        updatedAt
                        viewerCanUpdate
                        closed
                        owner {
                            ... on Organization {
                                login
                            }
                        }
                        fields(first: 30) {
                            nodes {
                                name
                                settings
                                createdAt
                                updatedAt
                            }
                        }
                    }
                }
            }' `
            -Variables @{
                projectId = $Id
            } `
            -BaseUri $BaseUri `
            -Token $Token

        if (!$result.node) {
            return
        }

        $fields = [ordered]@{ }
        foreach ($field in $result.node.fields.nodes) {
            $field.settings = $field.settings | ConvertFrom-Json
            $fields[$field.name] = $field
        }

        $result.node.fields = $fields

        $result.node
    }
}
