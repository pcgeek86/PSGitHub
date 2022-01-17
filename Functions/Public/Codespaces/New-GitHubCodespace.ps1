function New-GitHubCodespace {
  <#
  .SYNOPSIS
      Creates a codespace owned by the authenticated user in the specified repository.
  #>
  [CmdletBinding()]
  [OutputType('PSGitHub.Codespace')]
  param(
      [Parameter(Mandatory = $true)]
      [string] $Owner,

      [Parameter(Mandatory = $true, Position = 0)]
      [string] $RepositoryName,

      [string] $Location = 'WestUs2',
      # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
      # Defaults to "https://api.github.com"
      [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
      [Security.SecureString] $Token
  )

  process {
      $Path = 'repos/{0}/{1}/codespaces' -f $Owner, $RepositoryName
      $Body = @{
        location = $Location
      } | ConvertTo-Json
      Invoke-GitHubApi $Path -BaseUri $BaseUri -Token $Token -Method Post -Body $Body
  }
}

Export-ModuleMember -Alias @(
  (New-Alias -Name nghcs -Value New-GitHubCodespace -PassThru)
)
