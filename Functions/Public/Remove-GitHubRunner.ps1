function Remove-GitHubRunner {
  <#
  .SYNOPSIS
      Removes a registered GitHub Runner from a GitHub repository.
  #>
  [CmdletBinding()]
  [OutputType('PSGitHub.Runner')]
  param(
      [Parameter(Mandatory, Position = 0)]
      [string] $Owner,
      
      [Parameter(Mandatory, Position = 1)]
      [string] $Repo,
      
      [Parameter(Mandatory, Position = 2)]
      [int] $RunnerId,

      # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
      # Defaults to "https://api.github.com"
      [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
      [Security.SecureString] $Token
  )

  process {
      $Path = 'repos/{0}/{1}/actions/runners/{2}' -f $Owner, $Repo, $RunnerId
      $null = Invoke-GitHubApi $Path -BaseUri $BaseUri -Token $Token -Method Delete
  }
}

