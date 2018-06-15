$ErrorActionPreference = 'Stop'
$notFormatted = Get-ChildItem -Recurse '*.ps*' | ForEach-Object {
    $content = [IO.File]::ReadAllText($_.FullName).Replace("`r`n", "`n")
    if (!$content) {
        return
    }
    $formatted = Invoke-Formatter -ScriptDefinition $content
    if ($formatted -ne $content) {
        Write-Warning "Not formatted: $_"
        [IO.File]::WriteAllText($_.FullName, $formatted)
        $_
    }
}
if ($notFormatted) {
    throw "Found unformatted files"
}
