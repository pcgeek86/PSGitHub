function Update-GitHubGist {
    <#
    .Synopsis
    This command updates a GitHub Gist code snippet.

    .Description
    This command is responsible for updating GitHub Gist code snippets.

    .Notes

    .Link
    https://trevorsullivan.net
    https://developer.github.com/v3/gists
    #>
    [CmdletBinding()]
    param (
        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    $ApiCall = @{
        Body = '';
        Uri = '';
        Method = '';
        Token = $Token
        BaseUri = $BaseUri
    }

    Invoke-GitHubApi @ApiCall;
}

Export-ModuleMember -Alias (
    New-Alias -Name Set-GitHubGist -Value Update-GitHubGist -PassThru
)
