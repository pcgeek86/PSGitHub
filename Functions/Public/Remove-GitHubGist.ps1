function Remove-GitHubGist {
    <#
    .Synopsis
    This command deletes a GitHub Gist code snippet.
    
    .Description
    This command is responsible for deleting GitHub Gist code snippets or files.
    
    .Parameter Id
    The Id of the Gist to remove or remove files from.

    .Parameter FileName
    If this parameter is used, only specified files will be removed from the gist.

    .Example
    PS C:\> Get-GitHubGist -Id 265482c76983daedc83f | Remove-GitHubGist -Confirm:$false


    .Example
    PS C:\> Remove-GitHubGist -Id 265482c76983daedc83f -FileName File1.ps1, File2.ps1 -Confirm:$false


    .Notes
    This cmdlet will compliment Get-GitHubGist nicely.
      
    .Link
    https://trevorsullivan.net
    http://dotps1.github.io
    https://developer.github.com/v3/gists
    #>

    [CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess = $true)]
    [OutputType([Void])]

    Param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [String[]] $Id,
        [Parameter()]
        [String[]]$FileName
    )
    
    Process {
        foreach ($item in $Id) {
            if ($PSCmdlet.ShouldProcess($item)) {
                if ($FileName -ne $null) {
                    [HashTable]$body = @{
                        files = @{}
                    }
                    foreach ($file in $FileName) {
                        $body.files.Add($file, $null)
                    }
                    $restMethod = 'PATCH'
                } else {
                    $body = $null
                    $restMethod = 'DELETE'
                }
                
                $ApiCall = @{
                    Body = ConvertTo-Json -InputObject $body
                    RestMethod = 'gists/{0}' -f $item
                    Method = $restMethod
                }
    
                Invoke-GitHubApi @ApiCall
            }
        }
    }
}