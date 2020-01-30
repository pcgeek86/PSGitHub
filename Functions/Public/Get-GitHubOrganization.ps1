function Get-GitHubOrganization {
    [OutputType('PSGitHub.Organization')]
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (
        # Gets the org a specific user is part of.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'User')]
        [string] $Username,

        # Gets the org with a specific name.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Org')]
        [string] $OrganizationName,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token
    )

    $url = if ($Username) {
        "users/$Username/orgs"
    } elseif ($OrganizationName) {
        "orgs/$OrganizationName"
    } else {
        "organizations"
    }

    Invoke-GitHubApi $url -BaseUri $BaseUri -Token $Token | ForEach-Object { $_ } | ForEach-Object {
        $_.PSTypeNames.Insert(0, 'PSGitHub.Organization')
        $_
    }
}
