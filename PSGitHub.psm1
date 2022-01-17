### Created by Trevor Sullivan <trevor@trevorsullivan.net>

Get-ChildItem $PSScriptRoot/Functions -Recurse -File -Include *.ps1 | ForEach-Object {
    . $PSItem.FullName
}

Get-ChildItem $PSScriptRoot/Completers -Recurse -File -Include *.ps1 | ForEach-Object {
    . $PSItem.FullName
}

### Export all functions
Export-ModuleMember -Function *
