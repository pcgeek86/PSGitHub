function Remove-GitHubGist {
    <#
    .Synopsis
    This command deletes a GitHub Gist code snippet.
    
    .Description
    This command is responsible for deleting GitHub Gist code snippets.
    
    .Parameter Id
    The Id of the Gist to remove.

    .Example
    PS C:\> Get-GitHubGist -Id 265482c76983daedc83f | Remove-GitHubGist -Confirm:$false

    .Notes
    This cmdlet will compliment Get-GitHubGist nicely.
    This will remove the entire Gist, including all files, commits, and comments.
      
    .Link
    https://trevorsullivan.net
    http://dotps1.github.io
    https://developer.github.com/v3/gists
    #>
    [CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess = $true)]
    [OutputType([Void])]

    Param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [String[]] $Id
    )
    
    Process {
        foreach ($item in $Id) {
            if ($PSCmdlet.ShouldProcess($item)) {
                $ApiCall = @{
                    #Body = ''
                    RestMethod = 'gists/{0}' -f $item
                    Method = 'DELETE'
                }
    
                Invoke-GitHubApi @ApiCall
            }
        }
    }
}