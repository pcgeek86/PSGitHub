### Created by Trevor Sullivan <trevor@trevorsullivan.net>

#region Import Class definitions
$ClassList = Get-ChildItem -Path $PSScriptRoot\Classes;

foreach ($File in $ClassList) {
    . $File.FullName;
    Write-Verbose -Message ('Importing class file: {0}' -f $File.FullName);
}
#endregion

#region Import Private Functions
$FunctionList = Get-ChildItem -Path $PSScriptRoot\Functions\Private;

foreach ($File in $FunctionList) {
    . $File.FullName;
    Write-Verbose -Message ('Importing private function file: {0}' -f $File.FullName);
}
#endregion

#region Import Public Functions
$FunctionList = Get-ChildItem -Path $PSScriptRoot\Functions\Public;

foreach ($File in $FunctionList) {
    . $File.FullName;
    Write-Verbose -Message ('Importing public function file: {0}' -f $File.FullName);
}
#endregion

### Export all functions
Export-ModuleMember -Function *;