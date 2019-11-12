function Remove-GitHubGitRef {
    <#
    .SYNOPSIS
        Deletes a GitHub git ref (a branch, a commit, etc.)

    .EXAMPLE
        Remove-GitHubGitRef -Owner foo -RepositoryName bar -Ref heads/my-branch
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Owner,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[\w-\.]+$')]
        [Alias('Repository')]
        [string] $RepositoryName,

        [Parameter(Mandatory, ParameterSetName = 'Ref')]
        [ValidateNotNullOrEmpty()]
        [string] $Ref,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'HeadRef')]
        [ValidateNotNullOrEmpty()]
        [Alias('FriendlyName')]
        [string] $HeadRef,

        [Security.SecureString] $Token = (Get-GitHubToken)
    )
    process {
        if ($HeadRef) {
            $Ref = "heads/$HeadRef"
        }

        $shouldProcessCaption = "Deleting GitHub git ref"
        $shouldProcessDescription = "Deleting the GitHub git ref `e[1m$Name`e[0m in the repository `e[1m$Owner/$RepositoryName`e[0m."
        $shouldProcessWarning = "Do you want to create the GitHub git ref `e[1m$Name`e[0m in the repository `e[1m$Owner/$RepositoryName`e[0m?"

        if ($PSCmdlet.ShouldProcess($shouldProcessDescription, $shouldProcessWarning, $shouldProcessCaption)) {
            Invoke-GitHubApi -Method DELETE "/repos/$Owner/$RepositoryName/git/refs/$Ref" -Token $Token
            Write-Information "Removed GitHub git ref `e[1m$Ref`e[0m"
        }
    }
}
