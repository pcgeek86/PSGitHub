﻿function New-GitHubMilestone {
    <#
    .Synopsis
    Creates a new GitHub milestone.

    .Parameter Owner
    The GitHub username of the account or organization that owns the GitHub repository specified in the -RepositoryName parameter.

    .Parameter Repository
    Required. The name of the GitHub repository that is owned by the -Owner parameter, where the new GitHub milestone will be
    created.
    #>
    [CmdletBinding(DefaultParameterSetName = 'FindMilestones', SupportsShouldProcess)]
    [OutputType('PSGitHub.Milestone')]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('User')]
        [Alias('Organization')]
        [string] $Owner,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[\w-_\.]+$')]
        [Alias('Repository')]
        [string] $RepositoryName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string] $Title,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Description,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('open', 'closed')]
        [string] $State = 'open',

        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [DateTime] $DueOn,

        # Optional base URL of the GitHub API, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
        # Defaults to "https://api.github.com"
        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),
        [Security.SecureString] $Token
    )

    process {
        $body = @{
            title = $Title
            state = $State
            description = $Description
            due_on = $DueOn.ToString('yyyy-MM-dd')
        }

        $shouldProcessCaption = 'Creating new GitHub milestone'
        $shouldProcessDescription = "Creating the GitHub milestone `e[1m$Title`e[0m in the repository `e[1m$Owner/$RepositoryName`e[0m."
        $shouldProcessWarning = "Do you want to create the GitHub milestone `e[1m$Title`e[0m in the repository `e[1m$Owner/$RepositoryName`e[0m?"

        if ($PSCmdlet.ShouldProcess($shouldProcessDescription, $shouldProcessWarning, $shouldProcessCaption)) {

            Invoke-GitHubApi -Method POST "repos/$Owner/$RepositoryName/milestones" -Body ($body | ConvertTo-Json) -BaseUri $BaseUri -Token $Token | ForEach-Object {
                $_.PSTypeNames.Insert(0, 'PSGitHub.Milestone')
                $_.Creator.PSTypeNames.Insert(0, 'PSGitHub.User')
                if ($null -ne $_.DueOn) {
                    $_.DueOn = Get-Date -Date $_.DueOn -DisplayHint Date
                }
                $_
            }
        }
   }
}
