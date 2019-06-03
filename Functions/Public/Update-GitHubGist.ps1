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
        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    $ApiCall = @{
        Body = '';
        Uri = '';
        Method = '';
        Token = $Token
    }

    Invoke-GitHubApi @ApiCall;
}

Export-ModuleMember -Alias (
    New-Alias -Name Set-GitHubGist -Value Update-GitHubGist -PassThru
)
