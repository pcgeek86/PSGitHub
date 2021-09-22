function Invoke-GitHubGraphQlApi {
    <#
    .Synopsis
    An internal function that is responsible for invoking the GitHub GraphQL endpoint.

    .Parameter Headers
    A HashTable of the HTTP request headers as key-value pairs. Some features in the GitHub
    API do not require any request headers, in which case this parameter should not be specified.

    NOTE: Do not include the HTTP Authorization header in this HashTable, as the Authorization header
          will be set by this function.

    .Parameter BaseUri
    Optional base URL of the GitHub API to resolve Uri from, for example "https://ghe.mycompany.com/api/v3/" (including the trailing slash).
    Defaults to "https://api.github.com".

    .Parameter Token
    The GitHub OAuth token to use for authenticating the request.
    Create one at https://github.com/settings/tokens/new.
    Not all requests require a token.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string] $Query,

        $Variables = @{ },

        [Uri] $BaseUri = [Uri]::new('https://api.github.com'),

        # HTTP headers
        [HashTable] $Headers = @{ },

        [Security.SecureString] $Token
    )

    process {
        $Headers['User-Agent'] = 'PowerShell PSGitHub'

        # Resolve the Uri parameter with https://api.github.com as a base URI
        # This allows to call this function with just a path,
        # but also supply a full URI (e.g. for a GitHub enterprise instance)
        $Uri = [Uri]::new($BaseUri, 'graphql')

        $apiRequest = @{
            Headers = $Headers
            Uri = $Uri
            Method = 'POST'
        }

        # add the HTTP Authorization header to authenticate the HTTP request.
        if ($Token) {
            $apiRequest.Authentication = 'Bearer'
            $apiRequest.Token = $Token
        } else {
            Write-Verbose -Message 'Making request without API token'
        }


        $body = @{
            query = $Query
            variables = $Variables
        }

        $apiRequest.Body = $body | ConvertTo-Json -Depth 100
        Write-Verbose ("Query: " + $Query)
        Write-Verbose ("Variables: " + $Variables)

        # We need to communicate using TLS 1.2 against GitHub.
        [Net.ServicePointManager]::SecurityProtocol = 'tls12'

        # Invoke the REST API
        try {
            $result = Invoke-RestMethod @apiRequest -ResponseHeadersVariable responseHeaders
            if ($responseHeaders.ContainsKey('X-RateLimit-Limit')) {
                Write-Verbose "Rate limit total: $($responseHeaders['X-RateLimit-Limit'])"
                Write-Verbose "Rate limit remaining: $($responseHeaders['X-RateLimit-Remaining'])"
                $resetUnixSeconds = [int]($responseHeaders['X-RateLimit-Reset'][0])
                $resetDateTime = ([System.DateTimeOffset]::FromUnixTimeSeconds($resetUnixSeconds)).DateTime
                Write-Verbose "Rate limit resets: $resetDateTime"
            }
            if ($result.errors) {
                $result.errors | ForEach-Object message | Write-Error
            }
            $result.data
        } catch {
            if (
                $_.Exception.PSObject.TypeNames -notcontains 'Microsoft.PowerShell.Commands.HttpResponseException' -and # PowerShell Core
                $_.Exception -isnot [System.Net.WebException] # Windows PowerShell
            ) {
                # Throw any error that is not a HTTP response error (e.g. server not reachable)
                throw $_
            }
            # This is the only way to get access to the response body for errors in old PowerShell versions.
            # PowerShell >=7.0 could use -SkipHttpErrorCheck with -StatusCodeVariable
            $_.ErrorDetails.Message | Write-Error
        }
    }
}
