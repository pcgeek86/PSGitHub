@{
    Severity = @('Error', 'Warning', 'Information')
    ExcludeRules = @(
        'PSUseShouldProcessForStateChangingFunctions', # TODO: implement ShouldProcess
        'PSUseConsistentIndentation' # broken
    )
    Rules = @{
        PSPlaceOpenBrace = @{
            Enable = $true
            OnSameLine = $true
            NewLineAfter = $true
            IgnoreOneLineBlock = $true
        }

        PSPlaceCloseBrace = @{
            Enable = $true
            NewLineAfter = $false
            IgnoreOneLineBlock = $true
            NoEmptyLineBefore = $true
        }

        PSUseConsistentIndentation = @{
            Enable = $true
            Kind = 'space'
            IndentationSize = 4
        }

        PSUseConsistentWhitespace = @{
            Enable = $true
            CheckOpenBrace = $true
            CheckOpenParen = $true
            CheckOperator = $true
            CheckSeparator = $true
        }

        PSAlignAssignmentStatement = @{
            Enable = $false
        }

        PSUseShouldProcessForStateChangingFunctions = @{
            Enable = $true
        }

        PSUseCorrectCasing = @{
            Enable = $true
        }
    }
}
