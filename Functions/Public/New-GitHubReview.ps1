function New-GitHubReview {
    <#
    .SYNOPSIS
        Creates a review for the given pull request.
    #>
    [CmdletBinding(DefaultParameterSetName = 'PENDING')]
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

        # The SHA of the commit that needs a review. Not using the latest commit
        # SHA may render your review comment outdated if a subsequent commit
        # modifies the line you specify as the position. Defaults to the most
        # recent commit in the pull request when you do not specify a value.
        [string] $CommitId,

        [Parameter(Mandatory, ParameterSetName = 'REQUEST_CHANGES')]
        [switch] $RequestChanges,

        [Parameter(Mandatory, ParameterSetName = 'APPROVE')]
        [switch] $Approve,

        [Parameter(Mandatory, ParameterSetName = 'COMMENT')]
        [switch] $Comment,

        # Required when using REQUEST_CHANGES or COMMENT for the event
        # parameter. The body text of the pull request review.
        [Parameter(Position = 0, ParameterSetName = 'COMMENT')]
        [Parameter(Position = 0, ParameterSetName = 'APPROVE')]
        [Parameter(Position = 0, Mandatory, ParameterSetName = 'REQUEST_CHANGES')]
        [string] $Body,

        # Array of objects or hashtables with string path, int position and
        # string body fields.
        [ValidateNotNull()]
        [array] $Comments,

        [Security.SecureString] $Token
    )

    process {
        $Comments = @($Comments | Where-Object { $_ } | ForEach-Object {
            [PSCustomObject]@{
                path = [string]$_.Path
                position = [int]$_.Position
                body = [string]$_.Body
            }
        })
        $apiBody = @{
            event = $PSCmdlet.ParameterSetName
            comments = $Comments
        }
        if ($CommitId) {
            $apiBody.commit_id = $CommitId
        }

        Invoke-GithubApi -Method POST "/repos/$Owner/$RepositoryName/pulls/$Number/reviews" `
            -Body ($apiBody | ConvertTo-Json) `
            -Token $Token |
            ForEach-Object {
                $_.PSTypeNames.Insert(0, 'PSGitHub.Review')
                $_.User.PSTypeNames.Insert(0, 'PSGitHub.User')
                $_
            }
    }
}
