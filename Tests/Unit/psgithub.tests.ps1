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

    #region *-GitHubOrganization
    Describe 'Get-GitHubOrganization' {    
        Context 'Retrieving an Organization' {
            Mock -CommandName Invoke-GitHubApi -MockWith {
                return [PSCustomObject]@{
                    login = "github"
                    id = 9919
                    node_id = "MDEyOk9yZ2FuaXphdGlvbjM3ODU1NTY2"
                    url = "https://api.github.com/orgs/github"
                    repos_url = "https://api.github.com/orgs/github/repos"
                    events_url = "https://api.github.com/orgs/github/events"
                    hooks_url = "https://api.github.com/orgs/github/hooks"
                    issues_url = "https://api.github.com/orgs/github/issues"
                    members_url = "https://api.github.com/orgs/github/members{/member}"
                    public_members_url = "https://api.github.com/orgs/github/public_members{/member}"
                    avatar_url = "https://avatars1.githubusercontent.com/u/9919?v=4"
                    description = "How people build software."
                    name = "GitHub"
                    company = $null
                    blog = "https://github.com/about"
                    location = "San Francisco, CA"
                    email = "support@github.com"
                    is_verified = $true
                    has_organization_projects = $true
                    has_repository_projects = $true
                    public_repos = 306
                    public_gists = 0
                    followers = 0
                    following = 0
                    html_url = 'https://github.com/github'
                    created_at = "5/11/08 4:37:31 AM"
                    updated_at = "7/15/19 2:26:15 PM"
                    type = 'Organization'
                }
            }
            It 'Should return the payload of a single organization' {
                $test = Get-GitHubOrganization -Name 'github'
                $test.PSTypeNames[0] | Should -Be 'PSGitHub.Organization'

                Assert-MockCalled -CommandName Invoke-GitHubApi -Exactly -Times 1
            }
        }

        Context 'Retrieve a Users Organization Membership' {
            Mock -CommandName Invoke-GitHubApi -MockWith {
                return [PSCustomObject]@{
                    avatar_url = 'https://avatars1.githubusercontent.com/u/9919?v=4'
                    description = 'How people build software.'
                    events_url = 'https://api.github.com/orgs/github/events'
                    hooks_url = 'https://api.github.com/orgs/github/hooks'
                    id = 9919
                    issues_url = 'https://api.github.com/orgs/github/issues'
                    login = 'github'
                    members_url = 'https://api.github.com/orgs/github/members{/member}'
                    node_id = 'MDEyOk9yZ2FuaXphdGlvbjk5MTk='
                    public_members_url = 'https://api.github.com/orgs/github/public_members{/member}'
                    repos_url = 'https://api.github.com/orgs/github/repos'
                    url = 'https://api.github.com/orgs/github'
                }
            }
            It 'Should return a single org membership from a user' {
                $test = Get-GitHubOrganization -UserName 'michaelsainz'
                $test.PSTypeNames[0] | Should -Be 'PSGitHub.Organization'

                Assert-MockCalled -CommandName Invoke-GitHubApi -Exactly -Times 1
            }
        }
    }
    #endregion
}

Pop-Location
