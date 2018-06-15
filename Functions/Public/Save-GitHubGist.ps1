Function Save-GitHubGist {
    <#
    .Synopsis
    This command saves all files from a gist.

    .Description
    This command is responsible for saving each file that is associated with a gist to the local machine.

    .Parameter Path
    Path to create a parent folder named the 'ID' of the Gist, then places all Gist Content files that that directory.

    .Parameter Gist
    The Gist object to be saved.  Returned from Get-GitHubGist.

    .Example
    Get-GitHubGist -Id 62f8f608bdfec5d08552 | Save-GitHubGist


        Directory: C:\Users\me\Documents\GitHub\Gists\62f8f608bdfec5d08552


    Mode                LastWriteTime         Length Name
    ----                -------------         ------ ----
    -a----        3/21/2016   3:11 PM           2080 Register-SophosWebIntelligenceService.ps1

    .Notes
    This cmdlet will compliment Get-GitHubGist nicely.

    .Link
    https://trevorsullivan.net
    http://dotps1.github.io
    https://developer.github.com/v3/gists/
    #>

    [CmdletBinding()]
    [OutputType()]
    Param (
        [Parameter()]
        [String]$Path = "$env:APPDATA\PSGitHub\Gists",
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Object[]]$Gist
    )

    Process {
        foreach ($item in $Gist) {
            $directory = New-Item -Path $Path -Name $item.Id -ItemType Directory -Force
            foreach ($file in ($item.files.PSObject.Properties.Value)) {
                New-Item -Path $directory -Name $file.filename -ItemType File -Value $file.content
            }
        }
    }
}