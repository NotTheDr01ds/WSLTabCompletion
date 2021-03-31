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
            '^e $' { Get-WSLArgumentName }

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
                # If we're completing a partial value for a flag
                [String]$flag = $compTokens[-2]
                return Get-WSLArgumentValue $flag $wordToComplete
            }
            '^e.*f $' {
                # If the last token is a flag followed by a space,
                # then we need to check whether it has a value.  If
                # so, complete the value.
                [String]$flag = $compTokens[-1]
                if ($flags[$flag].hasValue) {
                    if ($flags[$flag].completionFunction) {
                        & $flags[$flag].completionFunction $wordToComplete
                    }
                }
                else {
                    # Otherwise, offer possible flag completions.
                    # Do not offer commands nor flags that have 
                    # already been used.
                    & Get-WSLArgumentName -OnlyFlags -Tokens $compTokens -ArgumentNamePartial $wordToComplete
                }
            }
            '^e.*fv $' {
                # If we're ending in a value, then the next token
                # should be a flag.  Note that we've already 
                # processed commands at this point.
                & Get-WSLArgumentName -OnlyFlags -Tokens $compTokens
            }
            '^e.*p$' {
                & Get-WSLArgumentName `
                  -OnlyFlags `
                  -Tokens $compTokens `
                  -ArgumentNamePartial $wordToComplete
            }
        }
    }
    Register-ArgumentCompleter -CommandName "wsl" `
        -ScriptBlock $Script:argCompFunction `
        -Native
}
