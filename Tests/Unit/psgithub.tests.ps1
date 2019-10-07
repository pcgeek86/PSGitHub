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
$ArtifactPath = "$ModuleRoot\Artifacts"
$null = New-Item `
    -Path $ArtifactPath `
    -ItemType Directory `
    -Force `
    -ErrorAction SilentlyContinue

Describe 'PSScriptAnalyzer' {
    Context 'PSGitHub Module, Functions and TabCompleters' {
        It 'Passes Invoke-ScriptAnalyzer' {
            # Perform PSScriptAnalyzer scan.
            $PSScriptAnalyzerResult = Invoke-ScriptAnalyzer -Path $ModuleRoot -Recurse -ErrorAction SilentlyContinue
            $PSScriptAnalyzerErrors = $PSScriptAnalyzerResult | Where-Object { $_.Severity -eq 'Error' }
            $PSScriptAnalyzerWarnings = $PSScriptAnalyzerResult | Where-Object { $_.Severity -eq 'Warning' }
            if ($PSScriptAnalyzerErrors -ne $null) {
                Write-Warning `
                    -Message 'There are PSScriptAnalyzer errors that need to be fixed:'
                @($PSScriptAnalyzerErrors).Foreach( {
                        Write-Warning -Message "$($_.Scriptname) (Line $($_.Line)): $($_.Message)"
                    } )
                Write-Warning `
                    -Message  'For instructions on how to run PSScriptAnalyzer on your own machine, please go to https://github.com/powershell/psscriptAnalyzer/'
                $PSScriptAnalyzerErrors | Should -BeNullOrEmpty
            }
            if ($PSScriptAnalyzerWarnings -ne $null) {
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
        $mockOwnerName = 'Mary'
        $mockRepositoryName = 'WebApps'
        $mockLabelName = 'Label1'

        $mockExpectedDefaultUri = 'repos/{0}/{1}/labels' -f $mockOwnerName, $mockRepositoryName

        BeforeAll {
            Mock -CommandName Invoke-GitHubApi
        }

        Context 'When getting first page of all labels in a repository' {
            It 'Should call the mock with the correct arguments' {
                Get-GitHubLabel -Owner $mockOwnerName -RepositoryName $mockRepositoryName

                Assert-MockCalled -CommandName Invoke-GitHubApi -Exactly -Times 1 -ParameterFilter {
                    $Method -eq 'Get' -and
                    $Uri -eq $mockExpectedDefaultUri
                }
            }
        }

        Context 'When getting second page of all labels in a repository' {
            It 'Should call the mock with the correct arguments' {
                Get-GitHubLabel -Owner $mockOwnerName -RepositoryName $mockRepositoryName -Page 2

                Assert-MockCalled -CommandName Invoke-GitHubApi -Exactly -Times 1 -ParameterFilter {
                    $Method -eq 'Get' -and
                    $Uri -eq $mockExpectedDefaultUri
                    $Body.page -eq 2
                }
            }
        }

        Context 'When getting a specific label in a repository' {
            It 'Should call the mock with the correct arguments' {
                Get-GitHubLabel -Owner $mockOwnerName -RepositoryName $mockRepositoryName -Name $mockLabelName

                Assert-MockCalled -CommandName Invoke-GitHubApi -Exactly -Times 1 -ParameterFilter {
                    $Method -eq 'Get' -and
                    $Uri -eq ('{0}/{1}' -f $mockExpectedDefaultUri, $mockLabelName)
                }
            }
        }
    }

    Describe 'New-GitHubLabel' {
        $mockOwnerName = 'Mary'
        $mockRepositoryName = 'WebApps'
        $mockLabelName = 'Label1'
        $mockLabelColor = 'ffffff'
        $mockLabelDescription = 'Label description'

        $newGitHubLabelParameters = @{
            Owner = $mockOwnerName
            RepositoryName = $mockRepositoryName
            Name = $mockLabelName
            Color = $mockLabelColor
        }

        $mockExpectedDefaultUri = 'repos/{0}/{1}/labels' -f $mockOwnerName, $mockRepositoryName

        $mockExpectedDefaultRequestBody = @{
            name = $mockLabelName
            color = $mockLabelColor
        }

        BeforeAll {
            Mock -CommandName Invoke-GitHubApi
        }

        Context 'When adding a new label without description' {
            It 'Should call the mock with the correct arguments' {
                New-GitHubLabel @newGitHubLabelParameters -Confirm:$false

                Assert-MockCalled -CommandName Invoke-GitHubApi -Exactly -Times 1 -ParameterFilter {
                    $Method -eq 'Post' -and
                    $Uri -eq $mockExpectedDefaultUri -and
                    $Body -eq ($mockExpectedDefaultRequestBody | ConvertTo-Json)
                }
            }
        }

        Context 'When adding a new label without description' {
            It 'Should call the mock with the correct arguments' {
                $mockTestParameters = $newGitHubLabelParameters.Clone()
                $mockTestParameters['Description'] = $mockLabelDescription

                New-GitHubLabel @mockTestParameters -Confirm:$false

                $mockExpectedRequestBody = $mockExpectedDefaultRequestBody.Clone()
                $mockExpectedRequestBody['description'] = $mockLabelDescription

                Assert-MockCalled -CommandName Invoke-GitHubApi -Exactly -Times 1 -ParameterFilter {
                    $Method -eq 'Post' -and
                    $Uri -eq $mockExpectedDefaultUri -and
                    $Body -eq ($mockExpectedRequestBody | ConvertTo-Json)
                }
            }
        }

        Context 'When adding a new label and requesting explicit validation' {
            It 'Should not not call any mock' {
                New-GitHubLabel @newGitHubLabelParameters -WhatIf

                Assert-MockCalled -CommandName Invoke-GitHubApi -Exactly -Times 0
            }
        }

        Context 'When adding a new label and requesting to forcibly execute' {
            It 'Should call the correct mock' {
                $ConfirmPreference = 'Medium'
                New-GitHubLabel @newGitHubLabelParameters -Force
                Assert-MockCalled -CommandName Invoke-GitHubApi -Exactly -Times 1
            }
        }
    }

    Describe 'Set-GitHubLabel' {
        $mockOwnerName = 'Mary'
        $mockRepositoryName = 'WebApps'
        $mockLabelName = 'Label1'
        $mockNewLabelName = 'NewName'
        $mockLabelColor = 'ffffff'
        $mockLabelDescription = 'Label description'

        $newGitHubLabelParameters = @{
            Owner = $mockOwnerName
            RepositoryName = $mockRepositoryName
            Name = $mockLabelName
        }

        $mockExpectedDefaultUri = 'repos/{0}/{1}/labels/{2}' -f $mockOwnerName, $mockRepositoryName, $mockLabelName

        BeforeAll {
            Mock -CommandName Invoke-GitHubApi
        }

        Context 'When updating a label with a new name' {
            It 'Should call the mock with the correct arguments' {
                $mockTestParameters = $newGitHubLabelParameters.Clone()
                $mockTestParameters['NewName'] = $mockNewLabelName

                Update-GitHubLabel @mockTestParameters -Confirm:$false

                $mockExpectedRequestBody = @{
                    name = $mockNewLabelName
                }

                Assert-MockCalled -CommandName Invoke-GitHubApi -Exactly -Times 1 -ParameterFilter {
                    $Method -eq 'Patch' -and
                    $Uri -eq $mockExpectedDefaultUri -and
                    $Body -eq ($mockExpectedRequestBody | ConvertTo-Json)
                }
            }
        }

        Context 'When updating a label with a new color' {
            It 'Should call the mock with the correct arguments' {
                $mockTestParameters = $newGitHubLabelParameters.Clone()
                $mockTestParameters['Color'] = $mockLabelColor

                Update-GitHubLabel @mockTestParameters -Confirm:$false

                $mockExpectedRequestBody = @{
                    name = $mockLabelName
                    color = $mockLabelColor
                }

                Assert-MockCalled -CommandName Invoke-GitHubApi -Exactly -Times 1 -ParameterFilter {
                    $Method -eq 'Patch' -and
                    $Uri -eq $mockExpectedDefaultUri -and
                    $Body -eq ($mockExpectedRequestBody | ConvertTo-Json)
                }
            }
        }

        Context 'When updating a label with a new description' {
            It 'Should call the mock with the correct arguments' {
                $mockTestParameters = $newGitHubLabelParameters.Clone()
                $mockTestParameters['Description'] = $mockLabelDescription

                Update-GitHubLabel @mockTestParameters -Confirm:$false

                $mockExpectedRequestBody = @{
                    name = $mockLabelName
                    description = $mockLabelDescription
                }

                Assert-MockCalled -CommandName Invoke-GitHubApi -Exactly -Times 1 -ParameterFilter {
                    $Method -eq 'Patch' -and
                    $Uri -eq $mockExpectedDefaultUri -and
                    $Body -eq ($mockExpectedRequestBody | ConvertTo-Json)
                }
            }
        }

        Context 'When updating a label with a new name, color and description' {
            It 'Should call the mock with the correct arguments' {
                $mockTestParameters = $newGitHubLabelParameters.Clone()
                $mockTestParameters['NewName'] = $mockNewLabelName
                $mockTestParameters['Color'] = $mockLabelColor
                $mockTestParameters['Description'] = $mockLabelDescription

                Update-GitHubLabel @mockTestParameters -Confirm:$false

                $mockExpectedRequestBody = @{
                    name = $mockNewLabelName
                    color = $mockLabelColor
                    description = $mockLabelDescription
                }

                Assert-MockCalled -CommandName Invoke-GitHubApi -Exactly -Times 1 -ParameterFilter {
                    $Method -eq 'Patch' -and
                    $Uri -eq $mockExpectedDefaultUri -and
                    $Body -eq ($mockExpectedRequestBody | ConvertTo-Json)
                }
            }
        }

        Context 'When adding a new label and requesting explicit validation' {
            It 'Should not not call any mock' {
                Update-GitHubLabel @newGitHubLabelParameters -WhatIf

                Assert-MockCalled -CommandName Invoke-GitHubApi -Exactly -Times 0
            }
        }

        Context 'When adding a new label and requesting to forcibly execute' {
            It 'Should call the correct mock' {
                $ConfirmPreference = 'Medium'
                Update-GitHubLabel @newGitHubLabelParameters -Force


                Assert-MockCalled -CommandName Invoke-GitHubApi -Exactly -Times 1
            }
        }
    }

    Describe 'Remove-GitHubLabel' {
        $mockOwnerName = 'Mary'
        $mockRepositoryName = 'WebApps'
        $mockLabelName = 'Label1'

        $newGitHubLabelParameters = @{
            Owner = $mockOwnerName
            RepositoryName = $mockRepositoryName
            Name = $mockLabelName
        }

        $mockExpectedDefaultUri = 'repos/{0}/{1}/labels/{2}' -f $mockOwnerName, $mockRepositoryName, $mockLabelName

        BeforeAll {
            Mock -CommandName Invoke-GitHubApi
        }

        Context 'When removing a label' {
            It 'Should call the mock with the correct arguments' {
                Remove-GitHubLabel @newGitHubLabelParameters -Confirm:$false

                Assert-MockCalled -CommandName Invoke-GitHubApi -Exactly -Times 1 -ParameterFilter {
                    $Method -eq 'Delete' -and
                    $Uri -eq $mockExpectedDefaultUri -and
                    $null -eq $Body
                }
            }
        }

        Context 'When removing a label and requesting explicit validation' {
            It 'Should not not call any mock' {
                Remove-GitHubLabel @newGitHubLabelParameters -WhatIf

                Assert-MockCalled -CommandName Invoke-GitHubApi -Exactly -Times 0
            }
        }

        Context 'When removing a label and requesting to forcibly execute' {
            It 'Should call the correct mock' {
                $ConfirmPreference = 'Medium'
                Remove-GitHubLabel @newGitHubLabelParameters -Force


                Assert-MockCalled -CommandName Invoke-GitHubApi -Exactly -Times 1
            }
        }
    }
    #endregion
}

Pop-Location
