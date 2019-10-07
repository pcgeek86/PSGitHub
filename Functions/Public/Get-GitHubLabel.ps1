function Get-GitHubLabel {
    <#
    .SYNOPSIS
    Gets GitHub labels.

    .DESCRIPTION
    This command retrieves GitHub labels for the specified repository using
    the authenticated user.

    .PARAMETER Owner
    The GitHub username of the account or organization that owns the GitHub
    repository specified in the parameter -RepositoryName parameter.

    .PARAMETER Repository
    The name of the GitHub repository, that is owned by the GitHub username
    specified by parameter -Owner.

    .PARAMETER Name
    Retrieve a single label with the specified name from the GitHub repository
    specified by the parameters -Owner and -RepositoryName.

    .PARAMETER Page
    The page number of the results to return. Default: 1

    .EXAMPLE
    # Retrieve all labels from the repository Mary/WebApps:
    Get-GitHubLabel -Owner Mary -RepositoryName WebApps

    .EXAMPLE
    # Retrieve only the label 'Label1' from the repository Mary/WebApps:
    Get-GitHubLabel -Owner Mary -RepositoryName WebApps -Name Label1

    #>
    [CmdletBinding()]
    [OutputType('PSGitHub.Label')]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('User')]
        [string] $Owner,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[\w-\.]+$')]
        [Alias('Repository')]
        [string] $RepositoryName,

        [ValidateRange(1, [int]::MaxValue)]
        [int] $Page,

        [string] $Name,

        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    $uri = 'repos/{0}/{1}/labels' -f $Owner, $RepositoryName

    if ($Name) {
        $uri += ("/{0}" -f $Name)
    }

    $queryParams = @{ }
    if ($Page) {
        $queryParams.page = $Page
    }

    $apiCall = @{
        Headers = @{
            Accept = 'application/vnd.github.symmetra-preview+json'
        }
        Body = $queryParams
        Method = 'Get'
        Uri = $uri
        Token = $Token
    }

    Invoke-GitHubApi @apiCall | ForEach-Object { $_ } | ForEach-Object {
        $_.PSTypeNames.Insert(0, 'PSGitHub.Label')
        $_
    }
}
