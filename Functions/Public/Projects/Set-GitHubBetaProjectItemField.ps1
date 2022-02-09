$betaProjectItemFragment = Get-Content -Raw "$PSScriptRoot/BetaProjectItemFragment.graphql"

function Set-GitHubBetaProjectItemField {
    <#
    .SYNOPSIS
        EXPERIMENTAL: Adds an item to a GitHub project (Beta).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [ValidateNotNullOrEmpty()]
        [string] $ItemNodeId,

        # The name of the field to set
        [Parameter(Mandatory)]
        [Alias('FieldName')]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        # The value to set the field to
        [Parameter(Mandatory)]
        [Alias('FieldValue')]
        [string] $Value,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token
    )
    process {
        # Get project for the item and find the ID of the field by name
        $project = Invoke-GitHubGraphQlApi `
            -Headers @{ 'GraphQL-Features' = 'projects_next_graphql' } `
            -Query 'query($itemId: ID!) {
                node(id: $itemId) {
                    ... on ProjectNextItem {
                        project {
                            id
                            fields(first: 20) {
                                nodes {
                                    id
                                    name
                                    settings
                                }
                            }
                        }
                    }
                }
            }' `
            -Variables @{ itemId = $ItemNodeId } `
            -BaseUri $BaseUri `
            -Token $Token `
            -ErrorAction Stop |
            ForEach-Object { $_.node.project }

        $fields = $project.fields.nodes

        # Parse JSON field
        foreach ($field in $fields) {
            $field.settings = $field.settings | ConvertFrom-Json
        }

        $field = $fields | Where-Object { $_.name -eq $Name }
        if (!$field) {
            throw "Field name does not exist: `"$Name`". Existing fields are: $($fields | ForEach-Object { '"' + $_.name + '"' })"
        }

        $update = @{
            projectId = $project.id
            itemId = $ItemNodeId
            fieldId = $field.id
            value = $Value
        }

        # If the field is a select, we need to get the option ID for the provided value.
        if ($field.settings -and $field.settings.PSObject.Properties['options']) {
            $option = $field.settings.options | Where-Object { $_.name -eq $Value }
            if (!$option) {
                Write-Error "Invalid option value provided for field `"$Name`": `"$Value`". Available options are: $($field.settings.options | ForEach-Object { '"' + $_.name + '"' })"
            }
            $update.value = $option.id
        }

        Invoke-GitHubGraphQlApi `
            -Headers @{ 'GraphQL-Features' = 'projects_next_graphql' } `
            -Query ('mutation($update: UpdateProjectNextItemFieldInput!) {
                updateProjectNextItemField(input: $update) {
                    projectNextItem {
                        ...BetaProjectItemFragment
                    }
                }
            }
            ' + $betaProjectItemFragment) `
            -Variables @{
                update = $update
            } `
            -BaseUri $BaseUri `
            -Token $Token |
            ForEach-Object { $_.updateProjectNextItemField.projectNextItem }
    }
}
