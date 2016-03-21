Function Save-GitHubGist {
    <#
    .Synopsis
    This command saves all files from a gist.

    .Description
    This command is responsable for saving each file that is assosiated with a gist to the local machine.

    .Notes
    This cmdlet will compliment Get-GitHubGist nicely.

    .Example
    Get-GitHubGist -Id 62f8f608bdfec5d08552 | Save-GitHubGist
    

        Directory: C:\Users\me\Documents\GitHub\Gists\62f8f608bdfec5d08552


    Mode                LastWriteTime         Length Name                                                                                                                                                                                                                                     
    ----                -------------         ------ ----                                                                                                                                                                                                                                     
    -a----        3/21/2016   3:11 PM           2080 Register-SophosWebIntelligenceService.ps1  
    
    .Link
    https://trevorsullivan.net
    http://dotps1.github.io
    https://developer.github.com/v3/gists/
    #>
    [CmdletBinding()]
    [OutputType()]
    Param (
        [Parameter()]
        [String]$Path = "$env:USERPROFILE\Documents\GitHub\Gists",
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Object[]]$Gist
    )

    Process {
        for ($i = 0; $i -lt $Gist.Length; $i++) {
            $directory = New-Item -Path $Path -Name $Gist[$i].Id -ItemType Directory -Force
            foreach ($file in ($Gist[$i].files.PSObject.Properties.Value)) {
                New-Item -Path $directory -Name $file.filename -ItemType File -Value $file.content
            }
        }
    }
}