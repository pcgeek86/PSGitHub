function Set-GitHubAuthenticatedUser {
    <#
    .Synopsis
    Updates information for the authenticated user.

    .Example
    ### Update the user's company
    Set-GitHubAuthenticatedUser -Company Microsoft;

    .Example
    ### Update the user's location and hireable status
    Set-GitHubAuthenticatedUser -Hireable $false -Location 'Denver, Colorado'

    .Notes
    Created by Trevor Sullivan <trevor@trevorsullivan.net>
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string] $Name
      , [Parameter(Mandatory = $false)]
        [string] $Email
      , [Parameter(Mandatory = $false)]
        [string] $Blog
      , [Parameter(Mandatory = $false)]
        [string] $Company
      , [Parameter(Mandatory = $false)]
        [string] $Location
      , [Parameter(Mandatory = $false)]
        [Alias('CanHire')]
        [bool] $Hireable
      , [Parameter(Mandatory = $false)]
        [Alias('Bio')]
        [string] $Biography

    )

    $Body = @{
        };
    if ($Name) { $Body.Add('name', $Name) }
    if ($Email) { $Body.Add('email', $Email) }
    if ($Blog) { $Body.Add('blog', $Blog) }
    if ($Company) { $Body.Add('company', $Company) }
    if ($Location) { $Body.Add('location', $Location) }
    if ($Hireable) { $Body.Add('hireable', [bool]$Hireable) }
    if ($Biography) { $Body.Add('biography', $Biography) }

    $Body = $Body | ConvertTo-Json;
    Write-Verbose -Message $Body;

    Invoke-GitHubApi -RestMethod user -Body $Body -Method Patch;

}
