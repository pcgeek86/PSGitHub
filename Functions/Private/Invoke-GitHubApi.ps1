function Invoke-GitHubApi {
    <#
    .Synopsis
    An internal function that is responsbile for invoking various GitHub REST methods.

    .Parameter Headers
    A HashTable of the HTTP request headers as key-value pairs. Some REST methods in the GitHub
    API do not require any request headers, in which case this parameter should not be specified.

    NOTE: Do not include the HTTP Authorization header in this HashTable, as the Authorization header
          will be set by this function.
    
    .Parameter Method
    The HTTP method that will be used for the request.

    .Parameter RestMethod
    This parameter is a mandatory parameter that specifies the URL part, after the API's DNS name, that
    will be invoked. By default, all

    .Parameter Preview
    This will retrive the preview api, 
    by changing `Accept` header to `application/vnd.github.drax-preview+json`.

    .Parameter Anonymous
    If, for some reason, you need to ensure that the REST method is invoked anonymously, you can specify the
    -Anonymous switch parameter. This will prevent the HTTP Authorization header from being added to the 
    HTTP headers prior to invoking the REST method.

    .Notes
    Created by Trevor Sullivan <trevor@trevorsullivan.net>
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [HashTable] $Headers = @{'Accept' = 'application/vnd.github.v3+json'}
      , [Parameter(Mandatory = $false)]
        [string] $Method = 'Get'
      , [Parameter(Mandatory = $true)]
        [string] $RestMethod
      , [Parameter(Mandatory = $false)]
        [string] $Body
      , [switch] $Preview
      , [switch] $Anonymous
    )
    
    ### TODO: Truncate leading forward slashes for the -RestMethod parameter value.

    ### If the caller hasn't specified the -Anonymouse switch parameter, then add the HTTP Authorization header
    ### to authenticate the HTTP request.
    if (!$Anonymous) {
        if (!$Headers.Authorization) {
            $Headers.Add('Authorization', 'Basic ' + (Get-GitHubToken).GetNetworkCredential().Password)
        }
        else {
            $Headers.Authorization = 'Basic ' + (Get-GitHubToken).GetNetworkCredential().Password
        }

        Write-Verbose -Message ('Authorization header is: {0}' -f $Headers['Authorization']);
    }

    ### if the user applied Preview switch, added the header to retrive the preview api
    if ($Preview) {

        if (!$Headers.Accept) {
            $Headers.Add('Accept', 'application/vnd.github.drax-preview+json')
        }
        else {
            $Headers.Accept = 'application/vnd.github.drax-preview+json'
        }
        
        Write-Warning 'The API you are trying to retrive maybe preview'
        Write-Warning 'Therefore there may be a chance that the request is unsuccessful'
    }

    ### Build the REST API parameters as a HashTable for PowerShell Splatting (look it up, it's easy)
    $ApiRequest = @{
        Headers = $Headers;
        Uri = 'https://api.github.com/{0}' -f $RestMethod;
        Method = $Method;
    };
    Write-Verbose -Message ('Invoking the REST method: {0}' -f $ApiRequest.Uri)
        
    ### Append the HTTP message body (payload), if the caller specified one.
    if ($Body) { 
        $ApiRequest.Body = $Body 
        Write-Verbose "the request body is {0}" -f $Body
    }

    ### Invoke the REST API
    Invoke-RestMethod @ApiRequest;
}

