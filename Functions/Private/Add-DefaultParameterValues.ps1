
# Default parameter values do not get applied before a completer is invoked,
# but can contain important defaults like the Token
function Add-DefaultParameterValues {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Scope = 'Function')]
    [CmdletBinding()]
    param(
        [string] $Command,
        [hashtable] $Parameters
    )
    foreach ($entry in $global:PSDefaultParameterValues.GetEnumerator()) {
        $commandPattern, $parameter = $entry.Key.Split(':')
        if ($Command -like $commandPattern) {
            $Parameters.Add($parameter, $entry.Value)
        }
    }
}
