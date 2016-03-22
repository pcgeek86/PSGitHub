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
    [CmdletBinding(DefaultParameterSetName = '__AllParameterSets')]
    Param (
        [Parameter(ParameterSetName = 'Files', Mandatory = $true, ValueFromPipeline = $true)]
        [String[]]$Path,
        [Parameter()]
        [String]$Description,
        [Parameter()]
        [Switch] $Public
    )

    DynamicParam {
        if ($psISE -ne $null) {
            $attribute = New-Object -TypeName System.Management.Automation.ParameterAttribute -Property @{
                HelpMessage = 'Caputure the content of the current ISE tab.'
                Mandatory = $true
                ParameterSetName = 'IseScriptPane'
            }
            $collection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
            $collection.Add($attribute)
            $parameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter('IseScriptPane', [Switch], $collection)
            $dictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
            $dictionary.Add('IseScriptPane', $parameter)
            return $dictionary
        }
    }
    
    Process {
        [HashTable]$body = @{
            description = $Description
            public = $Public.IsPresent
            files = @{}
        }

        if ($PSCmdlet.ParameterSetName -ne 'IseScriptPane') {
            foreach ($item in $Path) {
                $body.files.Add($(Split-Path -Path $item -Leaf), @{ content = ((Get-Content -Path $item -Raw).PSObject.BaseObject) })
            }
        } else {
            $body.files.Add('untitled.ps1', @{ content = $psISE.CurrentPowerShellTab.Files.SelectedFile.Editor.Text })
        }

        $apiCall = @{
            Body = ConvertTo-Json -InputObject $body
            RestMethod = 'gists'
            Method = 'Post'
        }
    
        Invoke-GitHubApi @apiCall
    }
}