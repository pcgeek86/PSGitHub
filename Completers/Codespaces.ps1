$codespaceNameCompleter = {
  [CmdletBinding()]
  param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
  [hashtable] $TokenParam = @{}
  Add-DefaultParameterValues -Command $commandName -Parameters $TokenParam

  try {
    $CodespaceList = Get-GitHubCodespace @TokenParam
    foreach ($Codespace in $CodespaceList) {
      if ($Codespace.Name -match $wordToComplete) {
        Write-Output -InputObject $Codespace.Name
      }
    }
  }
  catch {
    #Set-Content -Path psgithub.error.log -Value $PSItem
  }
}

Get-Command -Module PSGitHub -Name *Codespace* | `
  Where-Object -FilterScript { $PSItem.Parameters -and $PSItem.Parameters.ContainsKey('CodespaceName') } | `
  ForEach-Object { Register-ArgumentCompleter -CommandName $PSItem.Name -ParameterName CodespaceName -ScriptBlock $codespaceNameCompleter }