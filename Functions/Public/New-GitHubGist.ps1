function New-GitHubGist {
    <#
    .Synopsis
    This command creates a new GitHub Gist code snippet.
    
    .Description
    This command is responsible for creating new GitHub Gist code snippets.
    
    .Notes
      
    .Link
    https://trevorsullivan.net
    http://dotps1.github.io
    https://developer.github.com/v3/gists
    #>
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        [String[]]$Path,
        [Parameter(Mandatory = $true)]
        [String]$Description,
        [Parameter()]
        [Switch] $Public
    )
    
    Process {
        [PSCustomObject]$gist = @{
            description = $Description
            public = $Public.IsPresent
            files = @{}
        }

        for ($i = 0; $i -lt $Path.Length; $i++) {
            $gist.Files.Add($(Split-Path -Path $Path[$i] -Leaf), @{ content = ((Get-Content -Path $Path[$i] -Raw).PSObject.BaseObject) })
        }

        $body = ConvertTo-Json -InputObject $gist

        $apiCall = @{
            Body = $body
            RestMethod = 'gists'
            Method = 'Post'
        }
    
        Invoke-GitHubApi @apiCall
    }
}