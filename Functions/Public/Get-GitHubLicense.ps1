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
    param(
        [Parameter(Mandatory = $false, Position = 0)]
        [string] $LicenseId,
        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    if (-Not ($LicenseId)) {
        $uri = 'licenses'
    }
    else {
        $uri = 'licenses/{0}' -f $LicenseId
    }

    $headers = @{
        Accept = 'application/vnd.github.drax-preview+json'
        Token  = $Token
    }
    Invoke-GitHubApi -Method get -Uri $uri -Headers $headers
}
