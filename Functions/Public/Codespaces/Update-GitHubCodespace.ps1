function Update-GitHubCodespace {
  <#
  .SYNOPSIS
      Updates a user's codespace.
  #>
  [CmdletBinding()]
  [OutputType('PSGitHub.Codespace')]
  param(
      [Parameter(Mandatory = $true, Position = 0)]
      [Alias('Name')]
      [string] $CodespaceName,

      [Parameter(Mandatory = $true, Position = 1)]
      [string] $Machine,

      # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
      # Defaults to "https://api.github.com"
      [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
      [Security.SecureString] $Token
  )

  process {
      $Path = 'user/codespaces/{0}' -f $CodespaceName
      $Body = @{
        machine = $Machine
      } | ConvertTo-Json
      $null = Invoke-GitHubApi $Path -BaseUri $BaseUri -Token $Token -Method Patch Body $Body
  }
}

Export-ModuleMember -Alias @(
  (New-Alias -Name upghcs -Value Update-GitHubCodespace -PassThru)
)
