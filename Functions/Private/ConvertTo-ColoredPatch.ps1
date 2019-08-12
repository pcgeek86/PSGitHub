# Syntax-highlights a git diff with ANSI color codes.
# Used in Format.ps1xml files.
function ConvertTo-ColoredPatch {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string] $Patch
    )
    process {
        ($Patch -split "`n" | ForEach-Object {
            if ($_.StartsWith('-')) {
                "`e[31m$_`e[0m"
            } elseif ($_.StartsWith('+')) {
                "`e[32m$_`e[0m"
            } elseif ($_.StartsWith('@@')) {
                $_ -replace '@@(.+)@@', "`e[36m@@`$1@@`e[0m"
            } elseif ($_.StartsWith('diff ') -or $_.StartsWith('index ') -or $_.StartsWith('--- ') -or $_.StartsWith('+++ ')) {
                "`e[1m$_`e[0m"
            } else {
                $_
            }
        }) -join "`n"
    }
}
