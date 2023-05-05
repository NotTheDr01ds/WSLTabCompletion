function Get-CompletionPattern {
    [OutputType([String])]
    Param (
        [Array]$Tokens,
        [String]$WordToComplete
    )

    for (($i = 0); $i -lt $Tokens.Count; $i++) {
        [String]$currentToken = $Tokens[$i]
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
    if (!$WordToComplete) {
        # There is a space after the last token
        # Otherwise, we should be completing the last token
        $compPattern += " "
    }
    return $compPattern
}