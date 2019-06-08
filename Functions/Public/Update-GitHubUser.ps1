function Update-GitHubUser {
    <#
    .Synopsis
    Updates information for the authenticated user.

    .Example
    ### Update the user's company
    Update-GitHubUser -Company Microsoft;

    .Example
    ### Update the user's location and hireable status
    Update-GitHubUser -Hireable $false -Location 'Denver, Colorado'

    .Notes
    Created by Trevor Sullivan <trevor@trevorsullivan.net>
    #>
    [CmdletBinding()]
    param (
        [string] $Name,
        [string] $Email,
        [string] $Blog,
        [string] $Company,
        [string] $Location,

        [Alias('CanHire')]
        [bool] $Hireable,

        [string] $Biography,
        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    $body = @{ }
    if ($Name) {
        $body.name = $Name
    }
    if ($Email) {
        $body.email = $Email
    }
    if ($Blog) {
        $body.blog = $Blog
    }
    if ($Company) {
        $body.company = $Company
    }
    if ($Location) {
        $body.location = $Location
    }
    if ($Hireable) {
        $body.hireable = [bool]$Hireable
    }
    if ($Biography) {
        $body.biography = $Biography
    }

    Invoke-GitHubApi -Method PATCH -Uri user -Body ($body | ConvertTo-Json) -Token $Token;
}

Export-ModuleMember -Alias @(
    (New-Alias -Name Set-GitHubAuthenticatedUser -Value Update-GitHubUser -PassThru),
    (New-Alias -Name Update-GitHubAuthenticatedUser -Value Update-GitHubUser -PassThru)
)
