function Remove-GitHubRepository {
    <#
    .Synopsis
    Deletes a GitHub repository, using the specified owner and repository name.

    .Notes
    Created by Trevor Sullivan <trevor@trevorsullivan.net>
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Owner
      , [Parameter(Mandatory = $true)]
        [string] $Name
    )

    $Method = 'repos/{0}/{1}' -f $Owner, $Name;
    Invoke-GitHubApi -RestMethod $Method -Method Delete;
}
