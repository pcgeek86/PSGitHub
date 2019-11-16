function Get-GitHubLicense {
    <#
    .SYNOPSIS
        this cmdlet the the licenses that github provide

    .DESCRIPTION
        this cmdlet uses github preview api: licenses, please read https://developer.github.com/v3/licenses/ for more detail

    .PARAMETER LicenseId
        the identifier of a licenses, this is provided by GitHub and not universal
        This is also called 'key' sometimes

    .EXAMPLE
        PS C:\> Get-GitHubLicense
        Get all the licenses that github provided

    .EXAMPLE
        PS C:\> Get-GitHubLicense mit
        Get the information about mit license

    #>
    [CmdletBinding()]
    [OutputType('PSGitHub.License')]
    param(
        [Parameter(Position = 0)]
        [string] $LicenseId,
        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    process {
        if (-Not ($LicenseId)) {
            $uri = 'licenses'
        } else {
            $uri = 'licenses/{0}' -f $LicenseId
        }

        $headers = @{
            Accept = 'application/vnd.github.drax-preview+json'
        }
        Invoke-GitHubApi -Method get -Uri $uri -Headers $headers -BaseUri $BaseUri -Token $Token | ForEach-Object { $_ } | ForEach-Object {
            $_.PSTypeNames.Insert(0, 'PSGitHub.License')
            $_
        }
    }
}
