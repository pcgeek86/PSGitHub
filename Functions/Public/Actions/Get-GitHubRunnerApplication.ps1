function Get-GitHubRunnerApplication {
  <#
  .SYNOPSIS
      Retrieves the URLs to download the GitHub Runner application archive, with the installation files.
  #>
  [CmdletBinding()]
  [OutputType('PSGitHub.RunnerApplication')]
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
      $Path = 'repos/{0}/{1}/actions/runners/downloads' -f $Owner, $RepositoryName
      Invoke-GitHubApi $Path -BaseUri $BaseUri -Token $Token |
          ForEach-Object { $_ } |
          ForEach-Object {
              $_.PSTypeNames.Insert(0, 'PSGitHub.RunnerApplication')
              $_
          }
  }
}

Export-ModuleMember -Alias @(
(New-Alias -Name gghrunapp -Value Get-GitHubRunnerApplication -PassThru)
)
