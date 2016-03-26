#
# This is a PowerShell Unit Test file.
# You need a unit test framework such as Pester to run PowerShell Unit tests. 
# You can download Pester from http://go.microsoft.com/fwlink/?LinkID=534084
#

$Global:ModuleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))

$OldLocation = Get-Location
Set-Location -Path $ModuleRoot
if (Get-Module PSGitHub -All)
{
    Get-Module PSGitHub -All | Remove-Module
}

Import-Module "$Global:ModuleRoot\PSGitHub.psd1" -Force -DisableNameChecking
$Global:ArtifactPath = "$Global:ModuleRoot\Artifacts"
$null = New-Item -Path "$Global:ArtifactPath" -ItemType Directory -Force -ErrorAction SilentlyContinue

# Perform PS Script Analyzer tests on module code only
$null = Set-PackageSource -Name PSGallery -Trusted -Force
$null = Install-Module -Name 'PSScriptAnalyzer' -Confirm:$False
Import-Module -Name 'PSScriptAnalyzer'

Describe 'PSScriptAnalyzer' {
    Context 'PSGitHub Module, Functions and TabCompleters' {
        It 'Passes Invoke-ScriptAnalyzer' {
            # Perform PSScriptAnalyzer scan.
            $PSScriptAnalyzerResult = Invoke-ScriptAnalyzer `
                -path "$ModuleRoot\PSGitHub.psm1" `
                -Severity Warning `
                -ErrorAction SilentlyContinue
            $PSScriptAnalyzerResult += Invoke-ScriptAnalyzer `
                -path "$ModuleRoot\Functions\Public\*.ps1" `
                -Severity Warning `
                -ErrorAction SilentlyContinue
            $PSScriptAnalyzerResult += Invoke-ScriptAnalyzer `
                -path "$ModuleRoot\Functions\Private\*.ps1" `
                -Severity Warning `
                -ErrorAction SilentlyContinue
            $PSScriptAnalyzerResult += Invoke-ScriptAnalyzer `
                -path "$ModuleRoot\TabCompleters\*.ps1" `
                -Severity Warning `
                -ErrorAction SilentlyContinue
            $PSScriptAnalyzerErrors = $PSScriptAnalyzerResult | Where-Object { $_.Severity -eq 'Error' }
            $PSScriptAnalyzerWarnings = $PSScriptAnalyzerResult | Where-Object { $_.Severity -eq 'Warning' }
            if ($PSScriptAnalyzerErrors -ne $null)
            {
                Write-Warning -Message 'There are PSScriptAnalyzer errors that need to be fixed:'
                @($PSScriptAnalyzerErrors).Foreach( { Write-Warning -Message "$($_.Scriptname) (Line $($_.Line)): $($_.Message)" } )
                Write-Warning -Message  'For instructions on how to run PSScriptAnalyzer on your own machine, please go to https://github.com/powershell/psscriptAnalyzer/'
                $PSScriptAnalyzerErrors.Count | Should Be $null
            }
            if ($PSScriptAnalyzerWarnings -ne $null)
            {
                Write-Warning -Message 'There are PSScriptAnalyzer warnings that should be fixed:'
                @($PSScriptAnalyzerWarnings).Foreach( { Write-Warning -Message "$($_.Scriptname) (Line $($_.Line)): $($_.Message)" } )
            }
        }
    }
}

InModuleScope PSGitHub {

#region Functions
#endregion
}

Set-Location -Path $OldLocation
