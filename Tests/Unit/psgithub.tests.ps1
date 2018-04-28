#
# This is a PowerShell Unit Test file.
# You need a unit test framework such as Pester to run PowerShell Unit tests.
# You can download Pester from http://go.microsoft.com/fwlink/?LinkID=534084
#

$ModuleRoot = "$($Script:MyInvocation.MyCommand.Path)\..\..\.."

Push-Location `
    -Path $ModuleRoot
Get-Module `
    -Name PSGitHub `
    -All | Remove-Module

Import-Module `
    -Name "$ModuleRoot\PSGitHub.psd1" `
    -Force `
    -DisableNameChecking
$Global:ArtifactPath = "$ModuleRoot\Artifacts"
$null = New-Item `
    -Path $ArtifactPath `
    -ItemType Directory `
    -Force `
    -ErrorAction SilentlyContinue

if (-not (Get-Module -Name PSScriptAnalyzer -ListAvailable)) {
    # Perform PS Script Analyzer tests on module code only
    $null = Set-PackageSource `
        -Name PSGallery `
        -Trusted `
        -Force
    $null = Install-Module `
        -Name PSScriptAnalyzer `
        -Confirm:$False
    Import-Module `
        -Name PSScriptAnalyzer
}

Describe 'PSScriptAnalyzer' {
    Context 'PSGitHub Module, Functions and TabCompleters' {
        It 'Passes Invoke-ScriptAnalyzer' {
            # Perform PSScriptAnalyzer scan.
            $PSScriptAnalyzerResult = Invoke-ScriptAnalyzer `
                -Path "$ModuleRoot\PSGitHub.psm1" `
                -Severity Warning `
                -ErrorAction SilentlyContinue
            $PSScriptAnalyzerResult += Invoke-ScriptAnalyzer `
                -Path "$ModuleRoot\Functions\Public\*.ps1" `
                -Severity Warning `
                -ErrorAction SilentlyContinue
            $PSScriptAnalyzerResult += Invoke-ScriptAnalyzer `
                -Path "$ModuleRoot\Functions\Private\*.ps1" `
                -Severity Warning `
                -ErrorAction SilentlyContinue
            $PSScriptAnalyzerResult += Invoke-ScriptAnalyzer `
                -Path "$ModuleRoot\TabCompleters\*.ps1" `
                -Severity Warning `
                -ErrorAction SilentlyContinue
            $PSScriptAnalyzerErrors = $PSScriptAnalyzerResult `
                | Where-Object { $_.Severity -eq 'Error' }
            $PSScriptAnalyzerWarnings = $PSScriptAnalyzerResult `
                | Where-Object { $_.Severity -eq 'Warning' }
            if ($PSScriptAnalyzerErrors -ne $null)
            {
                Write-Warning `
                    -Message 'There are PSScriptAnalyzer errors that need to be fixed:'
                @($PSScriptAnalyzerErrors).Foreach( {
                    Write-Warning -Message "$($_.Scriptname) (Line $($_.Line)): $($_.Message)"
                } )
                Write-Warning `
                    -Message  'For instructions on how to run PSScriptAnalyzer on your own machine, please go to https://github.com/powershell/psscriptAnalyzer/'
                $PSScriptAnalyzerErrors.Count | Should Be $null
            }
            if ($PSScriptAnalyzerWarnings -ne $null)
            {
                Write-Warning `
                    -Message 'There are PSScriptAnalyzer warnings that should be fixed if possible:'
                @($PSScriptAnalyzerWarnings).Foreach( {
                    Write-Warning -Message "$($_.Scriptname) (Line $($_.Line)): $($_.Message)"
                } )
            }
        }
    }
}

InModuleScope PSGitHub {
    #region *-GitHubLabel
    Describe 'Get-GitHubLabel' {
        BeforeAll {
            Mock -CommandName Invoke-GitHubApi

            $mockOwnerName = 'Mary'
            $mockRepositoryName = 'WebApps'
            $mockLabelName = 'Label1'
        }

        Context 'When getting first page of all labels in a repository' {
            It 'Should call the mock with the correct arguments' {
                { Get-GitHubLabel -Owner $mockOwnerName -Repository $mockRepositoryName } | Should -Not -Throw

                Assert-MockCalled -CommandName Invoke-GitHubApi -Exactly -Times 1 -ParameterFilter {
                    $Method -eq 'Get' `
                    -and $RestMethod -eq ('repos/{0}/{1}/labels' -f $mockOwnerName, $mockRepositoryName)
                }
            }
        }

        Context 'When getting second page of all labels in a repository' {
            It 'Should call the mock with the correct arguments' {
                { Get-GitHubLabel -Owner $mockOwnerName -Repository $mockRepositoryName -Page 2 } | Should -Not -Throw

                Assert-MockCalled -CommandName Invoke-GitHubApi -Exactly -Times 1 -ParameterFilter {
                    $Method -eq 'Get' `
                    -and $RestMethod -eq ('repos/{0}/{1}/labels?page=2' -f $mockOwnerName, $mockRepositoryName)
                }
            }
        }

        Context 'When getting a specific label in a repository' {
            It 'Should call the mock with the correct arguments' {
                { Get-GitHubLabel -Owner $mockOwnerName -Repository $mockRepositoryName -Name $mockLabelName } | Should -Not -Throw

                Assert-MockCalled -CommandName Invoke-GitHubApi -Exactly -Times 1 -ParameterFilter {
                    $Method -eq 'Get' `
                    -and $RestMethod -eq ('repos/{0}/{1}/labels/{2}' -f $mockOwnerName, $mockRepositoryName, $mockLabelName)
                }
            }
        }
    }
    #endregion
}

Pop-Location
