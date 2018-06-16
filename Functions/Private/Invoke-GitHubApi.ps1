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
        [HashTable] $Headers = @{Accept = 'application/vnd.github.v3+json'},
        [Microsoft.PowerShell.Commands.WebRequestMethod] $Method = [Microsoft.PowerShell.Commands.WebRequestMethod]::Get,
        [Parameter(Mandatory)]
        [string] $Uri,
        [string] $Body,
        [switch] $Anonymous,
        [Security.SecureString] $Token = (Get-GitHubToken)
    )

    # If the caller hasn't specified the -Anonymous switch parameter, then add the HTTP Authorization header
    # to authenticate the HTTP request.
    if (!$Anonymous -and $Token) {
        $tokenStr = [Management.Automation.PSCredential]::new('dummy', $Token).GetNetworkCredential().Password
        if (!$Headers.Authorization) {
            $Headers.Authorization = 'token ' + $tokenStr
        }

        Write-Verbose -Message ('Authorization header is: {0}' -f $Headers['Authorization']);
    }
    else {
        Write-Verbose -Message 'Making request without API token'
    }

    $Headers.Add('User-Agent', 'PowerShell')

    # Resolve the Uri parameter with https://api.github.com as a base URI
    # This allows to call this function with just a path,
    # but also supply a full URI (e.g. for a GitHub enterprise instance)
    $Uri = [Uri]::new([Uri]::new('https://api.github.com'), $Uri)

    $ApiRequest = @{
        Headers = $Headers;
        Uri     = $Uri;
        Method  = $Method;
    };

    ### Append the HTTP message body (payload), if the caller specified one.
    if ($Body) {
        $ApiRequest.Body = $Body
        Write-Verbose -Message ('the request body is {0}' -f $Body)
    }

    # We need to communicate using TLS 1.2 against GitHub.
    [Net.ServicePointManager]::SecurityProtocol = 'tls12'

    # Invoke the REST API
    Invoke-RestMethod @ApiRequest;
}
