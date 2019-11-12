function Invoke-GitHubApi {
    <#
    .Synopsis
    An internal function that is responsible for invoking various GitHub REST endpoint.

    .Parameter Headers
    A HashTable of the HTTP request headers as key-value pairs. Some REST endpoint in the GitHub
    API do not require any request headers, in which case this parameter should not be specified.

    NOTE: Do not include the HTTP Authorization header in this HashTable, as the Authorization header
          will be set by this function.

    .Parameter Method
    The HTTP method that will be used for the request.

    .Parameter Uri
    This parameter is a mandatory parameter that specifies the URL to request.
    If not absolute, it will be resolved relative to https://api.github.com.

    .Parameter Anonymous
    If, for some reason, you need to ensure that the REST method is invoked anonymously, you can specify the
    -Anonymous switch parameter. This will prevent the HTTP Authorization header from being added to the
    HTTP headers prior to invoking the REST method, even if -Token is provided.

    .Parameter Token
    The GitHub OAuth token to use for authenticating the request.
    Create one at https://github.com/settings/tokens/new.
    Not all requests require a token.

    .Notes
    Created by Trevor Sullivan <trevor@trevorsullivan.net>
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string] $Uri,

        [HashTable] $Headers = @{Accept = 'application/vnd.github.v3+json' },
        [Microsoft.PowerShell.Commands.WebRequestMethod] $Method = [Microsoft.PowerShell.Commands.WebRequestMethod]::Get,
        $Body,

        # Accept header to be added (for accessing preview APIs or different resource representations)
        [string[]] $Accept,

        [switch] $Anonymous,
        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    $Headers['User-Agent'] = 'PowerShell PSGitHub'

    if ($Accept) {
        $Headers.Accept = ($Accept -join ',')
    }

    # Resolve the Uri parameter with https://api.github.com as a base URI
    # This allows to call this function with just a path,
    # but also supply a full URI (e.g. for a GitHub enterprise instance)
    $Uri = [Uri]::new([Uri]::new('https://api.github.com'), $Uri)

    $apiRequest = @{
        Headers = $Headers;
        Uri = $Uri;
        Method = $Method;
        # enable automatic pagination
        # use | Select-Object -First to limit the result
        FollowRelLink = $true;
    };

    # If the caller hasn't specified the -Anonymous switch parameter, then add the HTTP Authorization header
    # to authenticate the HTTP request.
    if (!$Anonymous -and $Token) {
        $apiRequest.Authentication = 'Bearer'
        $apiRequest.Token = $Token
    } else {
        Write-Verbose -Message 'Making request without API token'
    }

    ### Append the HTTP message body (payload), if the caller specified one.
    if ($Body) {
        $apiRequest.Body = $Body
        Write-Verbose -Message ("Request body: " + ($Body | Out-String))
    }

    # We need to communicate using TLS 1.2 against GitHub.
    [Net.ServicePointManager]::SecurityProtocol = 'tls12'

    # Invoke the REST API
    try {
        Invoke-RestMethod @apiRequest -ResponseHeadersVariable responseHeaders
        Write-Verbose "Rate limit total: $($responseHeaders['X-RateLimit-Limit'])"
        Write-Verbose "Rate limit remaining: $($responseHeaders['X-RateLimit-Remaining'])"
        $resetUnixSeconds = [int]($responseHeaders['X-RateLimit-Reset'][0])
        $resetDateTime = ([System.DateTimeOffset]::FromUnixTimeSeconds($resetUnixSeconds)).DateTime
        Write-Verbose "Rate limit resets: $resetDateTime"
    } catch {
        if (
            $_.Exception.PSObject.TypeNames -notcontains 'Microsoft.PowerShell.Commands.HttpResponseException' -or # PowerShell Core
            $_.Exception -isnot [System.Net.WebException] # Windows PowerShell
        ) {
            # Throw any error that is not a HTTP response error (e.g. server not reachable)
            throw $_
        }
        $errors = , ($_.ErrorDetails.Message | ConvertFrom-Json)
        if ($null -ne $err.PSObject.Properties['errors']) {
            $errors += $err.errors
        }
        foreach ($err in $errors) {
            $message = ""
            $errorId = $null
            $docUrl = $null
            if ($null -ne $err.PSObject.Properties['code']) {
                $errorId = $err.code
                $message += "$($err.code): "
            }
            if ($null -ne $err.PSObject.Properties['field']) {
                $message += "$($err.field): "
            }
            if ($null -ne $err.PSObject.Properties['message']) {
                $message += $err.message
            }
            if ($null -ne $err.PSObject.Properties['documentation_url']) {
                $message += "`nSee $($err.documentation_url)"
                $docUrl = $err.documentation_url
            }
            $message += "`n$($Method.ToString().ToUpper()) $Uri $($_.Exception.Response.StatusCode)"
            Write-Error -Message $message -ErrorId $errorId -RecommendedAction $docUrl
        }
    }
}
