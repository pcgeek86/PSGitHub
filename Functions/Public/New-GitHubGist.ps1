function New-GitHubGist {
    <#
    .Synopsis
    This command creates a new GitHub Gist code snippet.

    .Description
    This command is responsible for creating new GitHub Gist code snippets.

    .Parameter Path
    Path(s) to files to use for content sources for the Gist.  Each file in the Gist will be created and named the same as the source file.

    .Parameter Descirption
    Description header for the Gist.

    .Parameter Public
    This switch will determine if the Gist is Public or Private.

    .Parameter IseScriptPane
    This parameter is only avaialbe in the PowerShell ISE, if used the content of the Gist file will be set to the current active Script Tab.

    .Parameter GistFileName
    This parameter is only availabe in the PowerShell ISE, the name of the file in the Gist, defaults to name in the tab.

    .Example
    PS C:\> New-GitHubGist -IseScriptPane -Public


    url          : https://api.github.com/gists/a26026bea6f85f377276
    forks_url    : https://api.github.com/gists/a26026bea6f85f377276/forks
    commits_url  : https://api.github.com/gists/a26026bea6f85f377276/commits
    id           : a26026bea6f85f377276
    git_pull_url : https://gist.github.com/a26026bea6f85f377276.git
    git_push_url : https://gist.github.com/a26026bea6f85f377276.git
    html_url     : https://gist.github.com/a26026bea6f85f377276
    files        : @{New-GitHubGist.ps1=}
    public       : True
    created_at   : 2016-03-23T16:00:59Z
    updated_at   : 2016-03-23T16:00:59Z
    description  :
    comments     : 0
    user         :
    comments_url : https://api.github.com/gists/a26026bea6f85f377276/comments
    owner        : @{login=dotps1; id=1016996; avatar_url=https://avatars.githubusercontent.com/u/1016996?v=3; gravatar_id=; url=https://api.github.com/users/dotps1; html_url=https://github.com/dotps1; followers_url=https://api.github.com/users/dotps1/followers;
                   following_url=https://api.github.com/users/dotps1/following{/other_user}; gists_url=https://api.github.com/users/dotps1/gists{/gist_id}; starred_url=https://api.github.com/users/dotps1/starred{/owner}{/repo};
                   subscriptions_url=https://api.github.com/users/dotps1/subscriptions; organizations_url=https://api.github.com/users/dotps1/orgs; repos_url=https://api.github.com/users/dotps1/repos; events_url=https://api.github.com/users/dotps1/events{/privacy};
                   received_events_url=https://api.github.com/users/dotps1/received_events; type=User; site_admin=False}
    forks        : {}
    history      : {@{user=; version=f4ad1eac3a3eb7ffc656e4b3a40875cf5fb9e539; committed_at=2016-03-23T16:00:59Z; change_status=; url=https://api.github.com/gists/a26026bea6f85f377276/f4ad1eac3a3eb7ffc656e4b3a40875cf5fb9e539}}
    truncated    : False

    .Notes
    The IseScriptPane ParameterSet can only be used from with the PowerShell ISE.

    .Link
    https://trevorsullivan.net
    http://dotps1.github.io
    https://developer.github.com/v3/gists
    #>

    [CmdletBinding(DefaultParameterSetName = '__AllParameterSets')]
    [OutputType([System.Object])]
    Param (
        [Parameter(HelpMessage = 'Path to file(s) where the content will be used for the Gist.', Mandatory, ParameterSetName = 'Files', ValueFromPipeline)]
        [ValidateScript( { if (Test-Path -Path $_) { $true } else { throw "Cannot find path: '$_' because it does not exist." } })]
        # TODO: Perhaps allow a path to a folder, and then create one Gist with all the files in the top level of the directory?  Just a thought, but for now, no folders.
        # Get-ChildItem -Path $_ -File
        [ValidateScript( { if (-not (Get-Item -Path $_).PSIsContainer) { $true } else { throw "Path must be to a file." } })]
        [String[]]$Path,
        [Parameter(HelpMessage = 'Description of the Gist.')]
        [String]$Description,
        [Parameter(HelpMessage = 'Allows the Gist to be viewed by others.')]
        [Switch] $Public,
        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    DynamicParam {
        # Only present this parameter set if running the PowerShell ISE.
        if ($null -ne $psISE) {
            # Build Attributes for the IseScriptPane Parameter.
            $iseScriptPaneAttributes = New-Object -TypeName System.Management.Automation.ParameterAttribute -Property @{
                HelpMessage = 'Captures the current active ISE Script Pane as Gist content.'
                Mandatory = $true
                ParameterSetName = 'IseScriptPane'
            }
            # Build Collection Object to hold Parameter Attributes.
            $iseScriptPaneCollection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
            $iseScriptPaneCollection.Add($iseScriptPaneAttributes)
            # Build Runtime Parameter with Collection Parameter Attributes.
            $iseScriptPaneParameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter  -ArgumentList ('IseScriptPane', [Switch], $iseScriptPaneCollection)

            # Build Attributes for GistFileName Parameter.
            $gistFileNameAttributes = New-Object -TypeName System.Management.Automation.ParameterAttribute -Property @{
                HelpMessage = 'The name of the Gist file.'
                ParameterSetName = 'IseScriptPane'
            }
            # Build Collection Object to hold Parameter Attributes.
            $gistFileNameCollection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
            $gistFileNameCollection.Add($gistFileNameAttributes)
            # Build Runtime Parameter with Collection Parameter Attributes.
            $gistFileNameParameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList ('GistFileName', [String], $gistFileNameCollection)

            # Build Runtime Dictionary and add Runtime Parameters to it.
            $dictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
            $dictionary.Add('IseScriptPane', $iseScriptPaneParameter)
            $dictionary.Add('GistFileName', $gistFileNameParameter)
            # Return dictionary of Runtime Paramters to the PSCmdlet.
            return $dictionary
        }
    }

    Process {
        # Build request body template.
        [HashTable]$body = @{
            description = $Description
            public = $Public.IsPresent
            files = @{ }
        }

        # If running from the console, the later else is not available.
        # Add content of file(s) or ISE Script Pane to the body.
        if ($PSCmdlet.ParameterSetName -ne 'IseScriptPane') {
            foreach ($item in $Path) {
                $body.files.Add($(Split-Path -Path $item -Leaf), @{ content = ((Get-Content -Path $item -Raw).PSObject.BaseObject) })
            }
        } else {
            if ([String]::IsNullOrEmpty($PSBoundParameters.GistFileName)) {
                $PSBoundParameters.GistFileName = $psISE.CurrentPowerShellTab.Files.SelectedFile.DisplayName.Replace('*', '')
            }
            $body.files.Add($PSBoundParameters.GistFileName, @{ content = $psISE.CurrentPowerShellTab.Files.SelectedFile.Editor.Text })
        }

        # Splat API call Parameters.
        $apiCall = @{
            Body = ConvertTo-Json -InputObject $body
            Uri = 'gists'
            Method = 'Post'
            Token = $Token
        }

        # Create the Gist.
        Invoke-GitHubApi @apiCall
    }
}
