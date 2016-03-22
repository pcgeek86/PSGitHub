function New-GitHubGist {
    <#
    .Synopsis
    This command creates a new GitHub Gist code snippet.
    
    .Description
    This command is responsible for creating new GitHub Gist code snippets.
    
    .Notes
     Would like to make it so you can send data right from the ise script pane to a new Gist.
      
    .Link
    https://trevorsullivan.net
    http://dotps1.github.io
    https://developer.github.com/v3/gists
    #>
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        [String[]]$Path,
        [Parameter()]
        [String]$Description,
        [Parameter()]
        [Switch] $Public
    )
    
    Process {
        [HashTable]$body = @{
            description = $Description
            public = $Public.IsPresent
            files = @{}
        }

        foreach ( $item in $Path) {
            $body.files.Add($(Split-Path -Path $item -Leaf), @{ content = ((Get-Content -Path $item -Raw).PSObject.BaseObject) })
        }

        $apiCall = @{
            Body = ConvertTo-Json -InputObject $body
            RestMethod = 'gists'
            Method = 'Post'
        }
    
        Invoke-GitHubApi @apiCall
    }
}