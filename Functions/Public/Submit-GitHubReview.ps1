function Submit-GitHubReview {
    <#
    .SYNOPSIS
        Submits a review for the given pull request.
    #>
    [CmdletBinding(DefaultParameterSetName = 'COMMENT')]
    [OutputType('PSGitHub.Review')]
    param(
        # Number of the pull request
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $Number,

        # The owner of the target repository
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidatePattern('^[\w-]+$')] # safety check to make sure no owner/repo slug (with slash) was passed
        [string] $Owner = (Get-GitHubUser -Token $Token).login, # This doesn't work for org repos.

        # The name of the target repository
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[\w-]+$')]
        [Alias('Repository')]
        [string] $RepositoryName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [int] $ReviewId,

        [Parameter(Mandatory, ParameterSetName = 'REQUEST_CHANGES')]
        [switch] $RequestChanges,

        [Parameter(Mandatory, ParameterSetName = 'APPROVE')]
        [switch] $Approve,

        # Required when using REQUEST_CHANGES or COMMENT for the event
        # parameter. The body text of the pull request review.
        [Parameter(Position = 0, ParameterSetName = 'COMMENT')]
        [Parameter(Position = 0, ParameterSetName = 'APPROVE')]
        [Parameter(Position = 0, Mandatory, ParameterSetName = 'REQUEST_CHANGES')]
        [string] $Body,

        [Security.SecureString] $Token
    )

    process {
        $apiBody = @{
            event = $PSCmdlet.ParameterSetName
            body = $Body
        }

        Invoke-GithubApi -Method POST "/repos/$Owner/$RepositoryName/pulls/$Number/reviews/$ReviewId/events" `
            -Body ($apiBody | ConvertTo-Json) `
            -Token $Token |
            ForEach-Object {
                $_.PSTypeNames.Insert(0, 'PSGitHub.Review')
                $_.User.PSTypeNames.Insert(0, 'PSGitHub.User')
                $_
            }
    }
}
