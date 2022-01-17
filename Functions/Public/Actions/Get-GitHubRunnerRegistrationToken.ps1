function Get-GitHubRunnerRegistrationToken {
  <#
  .SYNOPSIS
      Retrieves a registration token for GitHub Actions self-hosted runners. Pass this token to the GitHub Runner configuration script, to register it with a GitHub repository.
  #>
  [CmdletBinding()]
  [OutputType('PSGitHub.RunnerRegistrationToken')]
  param(
      [Parameter(Mandatory, Position = 0)]
      [string] $Owner,

      [Parameter(Mandatory, Position = 1)]
      [Alias('RepositoryName')]
      [string] $RepositoryName,

      # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
      # Defaults to "https://api.github.com"
      [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
      [Security.SecureString] $Token
  )

  process {
      $Path = 'repos/{0}/{1}/actions/runners/registration-token' -f $Owner, $RepositoryName
      Invoke-GitHubApi $Path -BaseUri $BaseUri -Token $Token -Method Post |
          ForEach-Object { $_ } |
          ForEach-Object {
              $_.PSTypeNames.Insert(0, 'PSGitHub.RunnerRegistrationToken')
              $_
          }
  }
}
