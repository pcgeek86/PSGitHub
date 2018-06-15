$ErrorActionPreference = 'Stop'
Get-ChildItem -Recurse '*.ps*' | ForEach-Object {
    $content = $(Get-Content -Raw -Encoding utf8 $_)
    if (!$content) {
        return
    }
    $formatted = Invoke-Formatter -ScriptDefinition $content
    if ($formatted -ne $content) {
        Write-Warning "Not formatted: $_"
        $formatted | Out-File -FilePath $_ -Encoding utf8
    }
}
