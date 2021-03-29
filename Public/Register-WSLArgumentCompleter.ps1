Function Register-WSLArgumentCompleter {
    $Script:argCompFunction = {
        param($wordToComplete, $commandAst, $cursorPosition)

        [int]$cursorPosition = $cursorPosition - $commandAst.Extent.StartOffset
        [String]$commandString = $commandAst.Extent.ToString()
        [String[]]$compTokens = $commandAst.CommandElements.ForEach({$_.Extent.Text})
        [String]$compPattern = ""

        for (($i = 0); $i -lt $compTokens.Count; $i++) {
            [String]$currentToken = $compTokens[$i]
            $compPattern += if ($i -eq 0) {
                # The executable
                'e'
            } elseif ($flags[$currentToken].isCommand) {
                # A command
                'c'
            } elseif ($flags[$currentToken]) {
                # A flag
                'f'
            } elseif ($currentToken[0] -eq '-') {
                # A partial (or invalid) flag or command
                'p'
            } else {
                # A value
                'v'
            }
        }
        if (!$wordToComplete) {
            $compPattern += " "
        }

        <#$astDump = ($commandAst | Out-String) -split "`r`n" | Where-Object { $_ -ne "" }

        $indentedAstString = ($astDump | ForEach-Object { "    ${_}"}) -join "`r`n"
        (
            "-----------------",
            "",
            "wordToComplete: '${wordToComplete}'",
            "cursorPosition: ${cursorPosition}",
            "Extent.StartOffset: $($commandAst.Extent.StartOffset)",
            "commandAst:",
            $indentedAstString,
            "commandString: '${commandString}'",
            ""
        ) -join "`r`n" | Out-File -Append -FilePath $completionLogFile#>

        if ($cursorPosition -lt $commandString.Length) {
            # Don't offer completions if the cursor isn't at the end of the line
            # (for now)
            return
        }
        switch -Regex ($compPattern) {
            # WSL-only, no arguments or values yet
            # Then offer any matching flags or commands for completion
            '^e$' { Get-WSLArgumentName "" }

            # Any command in the first position
            # Then only offer the completion function for
            # that command or the default completer
            '^ec.*' {
                [String]$commandFlag = $compTokens[1]
                if ($flags[$commandFlag].completionFunction) {
                    & $flags[$commandFlag].completionFunction $wordToComplete
                }
            }
            '^ep$' {
                # If the first token is the beginning of a flag or command
                # Then offer any matching flags or commands for completion
                return Get-WSLArgumentName $wordToComplete
            }
            '^e.*fv$' {
                # If we're completing a value for a flag
                [String]$flag = $compTokens[-2]
                return Get-WSLArgumentValue $flag $wordToComplete
            }
            # If the first token 
            '^ef$' {
            }
        # If the last token is a flag
        '^e.*f$' {
            switch -Regex ($wordToComplete) {
                '^-{1,2}' {
                    # If the token being completed starts with a hyphen
                    # Then offer any matching flags or commands for completion
                    $alreadyUsedFlags = $compTokens | Where-Object { $_ -match '^-{0,1}' }
                    $validFlags = $flags.Keys
                    $flags.Keys | ForEach-Object {
                    }
                    return $validFlags -join " "
                    return Get-WSLArgumentName $wordToComplete
                }
                '' {
                    $flag = $compTokens[-1]
                    return Get-WSLArgumentValue $flag $wordToComplete
                }
            }
        }
<#             Default {
                if ($commandString -eq "wslx") {
                    # If there are no arguments yet (only "wsl" command typed)
                    # Then offer all flags and commands for completion
                    Get-WSLArgumentName ""

                } elseif ($wordToComplete -match "^-{1,2}") {
                    # If the token being completed starts with a hyphen
                    # Then offer any matching flags or commands for completion
                    Get-WSLArgumentName $wordToComplete 

                } elseif ($wordToComplete -ne "") {
                    # We've already checked for the word being a flag (starting with a dash)
                    # So this must be intended as a value
                    [String]$previousElement = $commandAst.CommandElements[-2].Extent.Text
                    if ($previousElement -match "^-") {
                        Get-WSLArgumentValue $previousElement $wordToComplete
                    }

                    #$argument = $commandAst.CommandElements[-2].Extent.Text >> $completionLogFile
                } elseif ($commandString.Length -lt $cursorPosition) {
                    if ($wordToComplete -eq "") {
                        # If the cursor is at the end of the line with whitespace
                        if ($commandAst.CommandElements[-1].Extent.Text -match "^-{1,2}\w") {
                            # And the last token on the line is a flag/command
                            $argumentName = $commandAst.CommandElements[-1].Extent.Text
                            Get-WSLArgumentValue $argumentName ""
                        }
                    }
                }

            } #>
        }
    }
    Register-ArgumentCompleter -CommandName "wsl" `
        -ScriptBlock $Script:argCompFunction `
        -Native
}
