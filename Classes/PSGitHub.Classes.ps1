Class GitHubPlan {
    [Int]$Collaborators
    [String]$Name
    [Int]$PriavteRepos
    [Int]$Space

    # The plan object returned from the API call to a Gistcan be passed directly into this constructor.
    GitHubPlan([Object]$object) {
        $this.Collaborators = $object.collaborators
        $this.Name = $object.name
        $this.PriavteRepos = $object.private_repos
        $this.Space = $object.space
    }

    # Empty Constructor.
    GitHubPlan() { }
}

Class GitHubGistOwner {
    [String]$AvatarUrl
    [String]$EventsUrl
    [String]$FollowersUrl
    [String]$FollowingUrl
    [String]$GistsUrl
    [String]$GravatarId
    [String]$HtmlUrl
    [String]$Id
    [String]$Login
    [String]$OrganizationsUrl
    [String]$ReceivedEventsUrl
    [String]$ReposUrl
    [Bool]$SiteAdmin
    [String]$StarredUrl
    [String]$SubscriptionsUrl
    [String]$Type
    [String]$Url

    # The owner object returned from the API call to a Gist can be passed directly into this constructor.
    GitHubGistOwner([Object]$object) {
        $this.AvatarUrl = $object.avatar_url
        $this.EventsUrl = $object.events_url
        $this.FollowersUrl = $object.followers_url
        $this.FollowingUrl = $object.following_url
        $this.GistsUrl = $object.gists_url
        $this.GravatarId = $object.gravatar_id
        $this.HtmlUrl = $object.html_url
        $this.Id = $object.Id
        $this.Login = $object.login
        $this.OrganizationsUrl = $object.organizations_url
        $this.ReceivedEventsUrl = $object.received_events_url
        $this.ReposUrl = $object.repos_url
        $this.SiteAdmin = $object.site_admin
        $this.StarredUrl = $object.starred_url
        $this.SubscriptionsUrl = $object.subscriptions_url
        $this.Type = $object.type
        $this.Url = $object.url
    }

    # Empty Constructor.
    GitHubGistOwner() { }
}

# The Owner object returned from a Gist shares many of the properties of the Owner object returned from Get-GitHubAuthenticatedUser.
# Thus, the GitHubOwner class is derived from the GitHubGistOwner class.
Class GitHubOwner : GitHubGistOwner {
    [String]$Bio
    [String]$Blog
    [Int]$Collaborators
    [String]$Company
    [DateTime]$CreatedAt
    [Int]$DiskUsage
    [String]$Email
    [Int]$Followers
    [Int]$Following
    [Bool]$Hireable
    [String]$Location
    [String]$Name
    [GitHubPlan]$Plan
    [Int]$PrivateGists
    [Int]$PublicGists
    [Int]$PublicRepos
    [Int]$TotalOwnedRepos
    [Int]$TotalPrivateRepos
    [DateTime]$UpdatedAt

    # The owner object returned from the Get-GitHubAuthenticatedUser can be passed directly into this constructor.
    GitHubOwner([Object]$object) {
        $this.AvatarUrl = $object.avatar_url
        $this.Bio = $object.bio
        $this.Blog = $object.blog
        $this.Collaborators - $object.collaborators
        $this.Company = $object.company
        $this.CreatedAt = $object.created_at
        $this.DiskUsage = $object.disk_usage
        $this.Email = $object.email
        $this.EventsUrl = $object.events_url
        $this.Followers = $object.followers
        $this.Following = $object.following
        $this.FollowersUrl = $object.followers_url
        $this.FollowingUrl = $object.following_url
        $this.GistsUrl = $object.gists_url
        $this.GravatarId = $object.gravatar_id
        $this.Hireable = $object.hireable
        $this.HtmlUrl = $object.html_url
        $this.Id = $object.Id
        $this.Location = $object.location
        $this.Login = $object.login
        $this.Name = $object.name
        $this.Plan = $object.plan
        $this.PrivateGists = $object.private_gists
        $this.PublicGists = $object.public_gists
        $this.PublicRepos = $object.public_repos
        $this.OrganizationsUrl = $object.organizations_url
        $this.ReceivedEventsUrl = $object.received_events_url
        $this.ReposUrl = $object.repos_url
        $this.SiteAdmin = $object.site_admin
        $this.StarredUrl = $object.starred_url
        $this.SubscriptionsUrl = $object.subscriptions_url
        $this.TotalOwnedRepos = $object.total_owend_repos
        $this.TotalPrivateRepos = $object.total_private_repos
        $this.Type = $object.type
        $this.UpdatedAt = $object.updated_at
        $this.Url = $object.url
    }

    # Empty constructor.
    GitHubGistOwner() { }
}

Class GitHubGistFile {
    [String[]]$Content
    [String]$FileName
    [String]$Language
    [String]$RawUrl
    [Int]$Size
    [String]$Type
    [Bool]$Truncated

    # These properties are hard to locate, but they are the ones we care about.
    # <GistObject>.files.PSObject.Properties.Value
    # If a Gist is retreived by any means other then the Id, the content is stripped, hence the invoke rest method.
    GitHubGistFile([Object]$object) {
        $this.FileName = $object.filename
        $this.Language = $object.language
        $this.RawUrl = $object.raw_url
        $this.Size = $object.size
        $this.Type = $object.Type
        $this.Truncated = $object.truncated
        $this.Content = if ([String]::IsNullOrEmpty($object.content)) { $this.GetFileContent() } else { $object.content }
    }

    # Empty Constructor.
    GitHubGistFile() { }

    # Adds a method to get the content of a Gist file.
    [String[]] GetFileContent() {
        return Invoke-RestMethod -Method Post -Uri $this.RawUrl
    }
}

Class GitHubGist {
    [Int]$Comments
    [String]$CommentsUrl
    [String]$CommitsUrl
    [DateTime]$CreatedAt
    [string]$Description
    [GitHubGistFile[]]$Files
    [String]$ForksUrl
    [String]$HtmlUrl
    [String]$Id
    [GitHubGistOwner]$Owner
    [Bool]$Public
    [String]$PullUrl
    [String]$PushUrl
    [Bool]$Truncated
    [DateTime]$UpdatedAt
    [String]$Url
    
    # This contructor works passing a gist response from the API directly into it.
    GitHubGist([Object]$object) {
        $this.CommentsUrl = $object.comments_url
        $this.Comments = $object.comments
        $this.CommitsUrl = $object.commits_url
        $this.CreatedAt = $object.created_at
        $this.Description = $object.Description
        $this.Files = $object.files.PSObject.Properties.Value
        $this.ForksUrl = $object.forks_url
        $this.HtmlUrl = $object.html_url
        $this.Id = $object.id
        $this.Owner = $object.owner
        $this.Public =$object.public
        $this.PullUrl = $object.git_pull_url
        $this.PushUrl = $object.git_push_url
        $this.Truncated = $object.truncated
        $this.UpdatedAt = $object.updated_at
        $this.Url = $object.url
    }

    # Constructor for manually defining properties.
    # these are the properties that are settable when creating a new Gist via the API.
    GitHubGist([String]$Description, [GitHubGistFile[]]$Files, [Bool]$Public) {
        $this.Description = $Description
        $this.Files = $Files
        $this.Public = $Public
    }
}