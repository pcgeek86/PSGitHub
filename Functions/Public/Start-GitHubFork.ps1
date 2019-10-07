function Start-GitHubFork {
    <#
    .SYNOPSIS
        the cmdlet to create a fork.

    .DESCRIPTION
        this cmdlet creates a fork of a other's repo in your account, or an organization that you have access to.
        Forking is asynchronous.

    .PARAMETER Owner
        the owner of the repo that you want to fork, mandatory

    .PARAMETER Repository
        the name of the repo that you want to fork, mandatory

    .PARAMETER Organization
        the organization you want to fork the upstream repository to, optional
        leave this blank if you want to fork to your account

    .EXAMPLE
        fork the repo 'pcgeek86/PSGitHub' to my 'test-orgnization'
        PS C:\> New-GitHubFork -Owner pcgeek86 -RepositoryName PSGitHub -Organization test-orgnization -verbose

        fork the repo 'pcgeek86/PSGitHub' to my account
        PS C:\> New-GitHubFork -Owner pcgeek86 -RepositoryName PSGitHub

    #>
    [CmdletBinding()]
    [OutputType('PSGitHub.Repository')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Owner,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[\w-\.]+$')]
        [Alias('Repository')]
        [string] $RepositoryName,

        [string] $Organization
    )

    process {
        $body = @{ }
        if ($organization) {
            $body.organization = $organization
        }
        Invoke-GithubApi -Method POST "repos/$Owner/$RepositoryName/forks" -Body ($body | ConvertTo-Json) -Token $Token | ForEach-Object {
            $_.PSTypeNames.Insert(0, 'PSGitHub.Repository')
            $_
        }
    }
}

Export-ModuleMember -Alias (
    New-Alias -Name New-GitHubFork -Value Start-GitHubFork -PassThru
)
