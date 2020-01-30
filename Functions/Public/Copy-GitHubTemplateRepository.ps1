function Copy-GitHubTemplateRepository {
    <#
    .Synopsis
        Creates a new repository using a repository template.
    #>
    [CmdletBinding()]
    [OutputType('PSGitHub.Repository')]
    param (
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Owner,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $TemplateOwner,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $TemplateRepositoryName,

        [string] $Description,
        [switch] $Private,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token
    )

    process {

        $uri = "repos/$TemplateOwner/$TemplateRepository/generate"
        $body = @{
            name = $Name
            description = $Description
            owner = $Owner
            private = [bool]$Private
        }

        Invoke-GitHubApi -Method POST $uri -Body ($Body | ConvertTo-Json) -BaseUri $BaseUri -Token $Token | ForEach-Object {
            $_.PSTypeNames.Insert(0, 'PSGitHub.Repository')
            $_.TemplateRepository.PSTypeNames.Insert(0, 'PSGitHub.Repository')
            $_.Owner.Insert(0, 'PSGitHub.User')
            $_
        }
    }
}
