### Created by Trevor Sullivan <trevor@trevorsullivan.net>

Get-ChildItem $PSScriptRoot/Functions, $PSScriptRoot/Completers -Recurse -File -Filter *.ps1 | ForEach-Object {
    . $_.FullName;
}

### Export all functions
Export-ModuleMember -Function *
