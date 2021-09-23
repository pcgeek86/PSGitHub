function Add-GitHubBetaProjectItem {
    <#
    .SYNOPSIS
        EXPERIMENTAL: Adds an item to a GitHub project (Beta).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $ProjectNodeId,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('node_id')]
        [Alias('id')]
        [string] $ContentNodeId,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token
    )

    process {
        Invoke-GitHubGraphQlApi `
            -Headers @{ 'GraphQL-Features' = 'projects_next_graphql' } `
            -Query 'mutation($input: AddProjectNextItemInput!) {
                addProjectNextItem(input: $input) {
                    projectNextItem {
                        id
                        title
                        creator {
                            login
                        }
                        fieldValues(first: 20) {
                            nodes {
                                value
                                projectField {
                                    name
                                }
                                updatedAt
                            }
                        }
                        updatedAt
                        createdAt
                    }
                }
            }' `
            -Variables @{
                input = @{
                    projectId = $ProjectNodeId
                    contentId = $ContentNodeId
                }
            } `
            -BaseUri $BaseUri `
            -Token $Token |
            ForEach-Object { $_.addProjectNextItem.projectNextItem }
    }
}
