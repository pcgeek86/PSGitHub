function Get-GitHubOrganization {
    [OutputType('PSGitHub.Organization')]
    [CmdletBinding()]
    param (
        # Gets the org a specific user is part of.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'User')]
        [string] $Username,

        # Gets the org with a specific name.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Org')]
        [string] $OrganizationName,

        [Security.SecureString] $Token
    )

    $url = if ($Username) {
        "/users/$Username/orgs"
    } elseif ($OrganizationName) {
        "/orgs/$OrganizationName"
    } else {
        "/organizations"
    }

    Invoke-GitHubApi $url -Token $Token | ForEach-Object { $_ } | ForEach-Object {
        $_.PSTypeNames.Insert(0, 'PSGitHub.Organization')
        $_
    }
}
