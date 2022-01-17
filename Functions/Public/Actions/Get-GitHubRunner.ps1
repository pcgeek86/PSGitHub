function Get-GitHubRunner {
  <#
  .SYNOPSIS
      Retrieves the GitHub Runners registered to a GitHub repository.
  #>
  [CmdletBinding()]
  [OutputType('PSGitHub.Runner')]
  param(
      [Parameter(Mandatory, Position = 0)]
      [string] $Owner,
      
      [Parameter(Mandatory, Position = 1)]
      [Alias('Name')]
      [string] $RepositoryName,

      # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
      # Defaults to "https://api.github.com"
      [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
      [Security.SecureString] $Token
  )

  process {
      $Path = 'repos/{0}/{1}/actions/runners' -f $Owner, $RepositoryName
      Invoke-GitHubApi $Path -BaseUri $BaseUri -Token $Token |
          ForEach-Object { $_.runners } |
          ForEach-Object {
              $_.PSTypeNames.Insert(0, 'PSGitHub.Runner')
              $_
          }
  }
}

Export-ModuleMember -Alias @(
  (New-Alias -Name gghrun -Value Get-GitHubRunner -PassThru)
)
