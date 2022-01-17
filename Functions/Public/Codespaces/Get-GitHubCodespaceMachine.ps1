function Get-GitHubCodespaceMachine {
  <#
  .SYNOPSIS
      List the machine types a codespace can transition to use.
  #>
  [CmdletBinding()]
  [OutputType('PSGitHub.CodespaceMachine')]
  param(
    [Parameter(Mandatory = $true, Position = 0)]
    [Alias('Name')]
    [string] $CodespaceName,

    # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
    # Defaults to "https://api.github.com"
    [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
    [Security.SecureString] $Token
  )

  process {
    $Path = 'user/codespaces/{0}/machines' -f $CodespaceName
    Invoke-GitHubApi $Path -BaseUri $BaseUri -Token $Token |
        ForEach-Object { $_.machines } |
        ForEach-Object {
            $_.PSTypeNames.Insert(0, 'PSGitHub.CodespaceMachine')
            $_
        }
  }
}

