function Get-GitHubCodespace {
  <#
  .SYNOPSIS
      Lists the authenticated user's codespaces.
  #>
  [CmdletBinding()]
  [OutputType('PSGitHub.Codespace')]
  param(
      # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
      # Defaults to "https://api.github.com"
      [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
      [Security.SecureString] $Token
  )

  process {
    $Path = 'user/codespaces'
    Invoke-GitHubApi $Path -BaseUri $BaseUri -Token $Token |
        ForEach-Object { $_.codespaces } |
        ForEach-Object {
            $_.PSTypeNames.Insert(0, 'PSGitHub.Codespace')
            $_
        }
  }
}

Export-ModuleMember -Alias @(
  (New-Alias -Name gghcs -Value Get-GitHubCodespace -PassThru)
)
