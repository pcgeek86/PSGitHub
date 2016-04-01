# Class for a GitHubPlan.
# This object is only used within the GitHubOwner class.
Class GitHubPlan {
    [Int]$Collaborators
    [String]$Name
    [Int]$PriavteRepos
    [Int]$Space

    # The plan property of the object returend for fetching an authenticated user can be passed directly into this.
    # https://developer.github.com/v3/users/
    # GET /user
    GitHubPlan([Object]$object) {
        $this.Collaborators = $object.collaborators
        $this.Name = $object.name
        $this.PriavteRepos = $object.private_repos
        $this.Space = $object.space
    }

    # Empty Constructor.
    GitHubPlan() { }
}

# Class for a GitHubUser.
# This object can exist in multipule places through the Gist object, depending on the api call used.
Class GitHubUser {
    [Uri]$AvatarUrl
    [Uri]$EventsUrl
    [Uri]$FollowersUrl
    [Uri]$FollowingUrl
    [Uri]$GistsUrl
    [String]$GravatarId
    [Uri]$HtmlUrl
    [String]$Id
    [String]$Login
    [Uri]$OrganizationsUrl
    [Uri]$ReceivedEventsUrl
    [Uri]$ReposUrl
    [Bool]$SiteAdmin
    [Uri]$StarredUrl
    [Uri]$SubscriptionsUrl
    [String]$Type
    [Uri]$Url

    # The owner object returned from the API call to a Gist can be passed directly into this constructor.
    GitHubUser([Object]$object) {
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
    GitHubUser() { }
}

# The Owner object returned from a Gist shares many of the properties of the Owner object returned from Get-GitHubAuthenticatedUser.
# Thus, the GitHubOwner class is derived from the GitHubGistOwner class.
Class GitHubOwner : GitHubUser {
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
    GitHubOwner() { }
}

# Class for GitHubGistFile.
Class GitHubGistFile {
    [String[]]$Content
    [String]$FileName
    [String]$Language
    [Uri]$RawUrl
    [Int]$Size
    [String]$Type
    [Bool]$Truncated

    # These properties are hard to locate, but they are the ones we care about.
    # <GistObject>.files.PSObject.Properties.Value
    # If a Gist is retreived by any means other then the Id, the content is stripped, hence the invoke rest method.
    # This files property of the Gist object can be passed directoy into this constructor.
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
    # (Get-GitHubGist | Select -First 1).Files[0].GetContent()
    [String[]] GetFileContent() {
        return Invoke-RestMethod -Method Post -Uri $this.RawUrl
    }
}

# Class for GitHubFork.
# This object only exists in the Gist object if it was called using the -Id parameter
# Object may not be only used for Gists, so please rename is used with repos as well.
Class GitHubGistFork {
    [DateTime]$CreatedAt
    [String]$Id
    [DateTime]$UpdatedAt
    [GitHubUser]$User
    [Uri]$Url

    # The forks property of the Gist object can be passed directly into this constructor.
    GitHubGistFork([Object]$object) {
        $this.CreatedAt = $object.created_at
        $this.Id = $object.id
        $this.UpdatedAt = $object.updated_at
        $this.User = $object.user
        $this.Url = $object.url
    }

    # Empty Constructor.
    GitHubGistFork() { }
}

# Class for GitHubGistChangeStatus.
# This object only exists in the Gist object if it was called using the -Id parameter
# Object may not be only used for Gists, so please rename is used with repos as well.
Class GitHubGistChangeStatus {
    [Int]$Additions
    [Int]$Deletions
    [Int]$Total

    # The change_status property of the Gist object can be passed directly into this constructor.
    GitHubGistChangeStatus([Object]$object) {
        $this.Additions = $object.additions
        $this.Deletions = $object.deletions
        $this.Total = $object.total
    }

    # Empty Constructor.
    GitHubChangeStatus() { }
}

# GitHubGistHistory
# This object only exists in the Gist object if it was called using the -Id parameter
# Object may not be only used for Gists, so please rename is used with repos as well.
Class GitHubGistHistory {
    [GitHubGistChangeStatus]$ChangeStatus
    [DateTime]$CommittedAt
    [String]$Url
    [GitHubUser]$User
    [String]$Version

    # The history propty of the Gist object can be passed directly into this constructor.
    GitHubGistHistory([Object]$object) {
        $this.ChangeStatus = $object.change_status
        $this.CommittedAt = $object.committed_at
        $this.Url = $object.url
        $this.User = $object.user
        $this.Version = $object.version
    }

    # Empty Constructor.
    GitHubGistHistory() { }
}

# Class for GitHubGist.
Class GitHubGist {
    [Int]$Comments
    [Uri]$CommentsUrl
    [Uri]$CommitsUrl
    [DateTime]$CreatedAt
    [string]$Description
    [GitHubGistFile[]]$Files
    [GitHubGistFork[]]$Forks
    [Uri]$ForksUrl
    [GitHubGistHistory[]]$History
    [Uri]$HtmlUrl
    [String]$Id
    [GitHubUser]$Owner
    [Bool]$Public
    [Uri]$PullUrl
    [Uri]$PushUrl
    [Bool]$Truncated
    [DateTime]$UpdatedAt
    [Uri]$Url
    
    # This contructor works passing a gist response from the API directly into it.
    GitHubGist([Object]$object) {
        $this.CommentsUrl = $object.comments_url
        $this.Comments = $object.comments
        $this.CommitsUrl = $object.commits_url
        $this.CreatedAt = $object.created_at
        $this.Description = $object.Description
        $this.Files = $object.files.PSObject.Properties.Value
        $this.Forks = $object.forks
        $this.ForksUrl = $object.forks_url
        $this.History = $object.history
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

    # TODO: develope Create() and Delete() methods.
}
