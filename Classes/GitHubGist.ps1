class GitHubGistFile {
}

class GitHubGist {
    [string] $Name
    [string] $Description
    [string] $Owner
    [GitHubGistFile[]] $Files;

    GitHubGist() {
    }

    GitHubGist([string] $Name, [string] $Description, [string] $Owner) {
        $this.Name = $Name;
        $this.Owner = $Owner;
        $this.Description = $Description;
    }
}
