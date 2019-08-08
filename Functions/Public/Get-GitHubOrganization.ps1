function Get-GitHubOrganization {
	<#
	.SYNOPSIS
	Retrieve a GitHub Organization.

	.PARAMETER UserName
	The GitHub username/handle to query for organization memberships

	.PARAMETER Name
	The GitHub organization name to query against

	.PARAMETER Token
	The secure string representing a token used for authentication against the API
	#>
	[OutputType('PSGitHub.Organization')]
	[CmdletBinding()]
	param (
		# Gets the org a specific user is part of.
		[Parameter(ParameterSetName = 'UserMemberships',
			Mandatory = $false, 
			ValueFromPipelineByPropertyName = $true)]
		[Alias('Handle')]
		[string]$UserName,

	   # Hostname of the GitHub Enterprise Server ("GHES")
	   [Parameter(Mandatory = $false, 
		   ValueFromPipelineByPropertyName = $false)]
	   [Alias('ComputerName', 'Host')]
		[String]$HostName,

		# Gets the org with a specific name.
		[Parameter(ParameterSetName = 'Org',
			Mandatory = $false,
			ValueFromPipelineByPropertyName = $true)]
		[Alias('OrganizationName')]
		[string[]]$Name,

		# Secure token to use in authentication for this operation
		[Security.SecureString]$Token
	)

	Begin {

		Write-Debug -Message "Entered Function: Get-GitHubOrganization"

		If ($HostName) {
			Write-Debug -Message "Hostname is: $HostName"
			$BaseUrl = "https://$HostName/api/v3"
			Write-Debug -Message "BaseUrl is: $BaseUrl"
		}

		Else {
			Write-Debug -Message 'Setting BaseUrl to GitHub.com'
			$BaseUrl = 'https://api.github.com'
			Write-Debug -Message "BaseUrl is: $BaseUrl"
		}
	}

	Process {
		if ($PSCmdlet.ParameterSetName -eq 'Org') {
			foreach ($handle in $Name) {
				Write-Verbose -Message "Current Org Name: $handle"

				$Url = "$BaseUrl/orgs/$handle"
				Write-Debug -Message "Querying API at Url: $Url"

				Invoke-GitHubApi -Uri $Url -Token $Token | ForEach-Object { $_ } | ForEach-Object {
					Write-Verbose -Message "Type is: $(Out-String -InputObject (Get-Member -InputObject $_))"
					$_.PSTypeNames.Insert(0, 'PSGitHub.Organization')
					$_
				}
			}
		}

		elseif ($PSCmdlet.ParameterSetName -eq 'UserMemberships') {
			Write-Verbose -Message "Retrieving user memberships for user: $UserName"

			$Url = "$BaseUrl/users/$Username/orgs"
			Write-Debug -Message "Querying API at Url: $Url"

			Invoke-GitHubApi -Uri $Url -Token $Token | ForEach-Object { $_ } | ForEach-Object {
				$_.PSTypeNames.Insert(0, 'PSGitHub.Organization')
				$_
			}
		}
	}
}
