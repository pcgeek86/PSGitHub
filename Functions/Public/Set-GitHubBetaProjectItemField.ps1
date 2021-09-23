function Set-GitHubBetaProjectItemField {
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
        [string] $ItemNodeId,

        # The name of the field to set
        [Parameter(Mandatory)]
        [Alias('FieldName')]
        [string] $Name,

        # The value to set the field to
        [Parameter(Mandatory)]
        [Alias('FieldValue')]
        $Value,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token
    )
    begin {
        # Find the ID of the field by name
        $fields = Invoke-GitHubGraphQlApi `
            -Headers @{ 'GraphQL-Features' = 'projects_next_graphql' } `
            -Query 'query($projectId: ID!) {
                node(id: $projectId) {
                    ... on ProjectNext {
                        fields(first: 20) {
                            nodes {
                                id
                                name
                            }
                        }
                    }
                }
            }' `
            -Variables @{ projectId = $ProjectNodeId } `
            -BaseUri $BaseUri `
            -Token $Token |
            ForEach-Object { $_.node.fields.nodes }
        $field = $fields | Where-Object { $_.name -eq $Name }
        if (!$field) {
            throw "Field name does not exist: `"$Name`". Existing fields are: $($fields | ForEach-Object name)"
        }
    }
    process {
        Invoke-GitHubGraphQlApi `
            -Headers @{ 'GraphQL-Features' = 'projects_next_graphql' } `
            -Query 'mutation($input: UpdateProjectNextItemFieldInput!) {
                updateProjectNextItemField(input: $input) {
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
                    itemId = $ItemNodeId
                    fieldId = $field.id
                    value = $Value
                }
            } `
            -BaseUri $BaseUri `
            -Token $Token |
            ForEach-Object { $_.addProjectNextItem.projectNextItem }
    }
}
