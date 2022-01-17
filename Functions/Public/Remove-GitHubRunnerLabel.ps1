function Remove-GitHubRunnerLabel {
  <#
  .SYNOPSIS
      Removes a label from a GitHub Runner that's registered to a GitHub repository.
  #>
  [CmdletBinding()]
  [OutputType('PSGitHub.RunnerLabels')]
  param(
      [Parameter(Mandatory, Position = 0)]
      [string] $Owner,

      [Parameter(Mandatory, Position = 1)]
      [string] $Repo,

      [Parameter(Mandatory, Position = 2)]
      [string] $RunnerId,

      [Parameter(Mandatory, Position = 2)]
      [string] $Label,

      # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
      # Defaults to "https://api.github.com"
      [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
      [Security.SecureString] $Token
  )

  process {
      $Path = 'repos/{0}/{1}/actions/runners/{2}/labels/{3}' -f $Owner, $Repo, $RunnerId, $Label
      Invoke-GitHubApi $Path -BaseUri $BaseUri -Token $Token -Method Delete -Body $Body |
          ForEach-Object { $_ } |
          ForEach-Object {
              $_.PSTypeNames.Insert(0, 'PSGitHub.RunnerLabels')
              $_
          }
  }
}
