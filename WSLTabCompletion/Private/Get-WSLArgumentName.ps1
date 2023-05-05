function Get-WSLArgumentName {
    param(
        [String]$ArgumentNamePartial = "",
        [Switch]$OnlyFlags,
        [Array]$Tokens
    )

    # Our validArguments start out being all of the defined $flags.
    # If there's a partially supplied argument name, then filter out
    # any arguments that don't match
    [Array]$validArguments = $flags.Keys | Where-Object { $_ -match $ArgumentNamePartial }

    # If we're asking for only flags, then filter out any commands
    if ($OnlyFlags.IsPresent) {
        $validArguments = $validArguments | Where-Object { !$flags[$_].isCommand }
    }

    if ($Tokens) {
        $usedFlags = $Tokens | Where-Object { $_ -match '^-{1,2}|~' }
        $usedFlags = $usedFlags | ForEach-Object {
            if ($flags[$_].synonyms) {
                $flags[$_].synonyms
            } else {
                $_
            }
        }
        $validArguments = $validArguments | Where-Object {
            $_ -notin $usedFlags
        }
    }

    $validArguments | ForEach-Object {
        if (!$flags[$_].description) { $flags[$_].description = "Null"}
        New-Object -Type System.Management.Automation.CompletionResult -ArgumentList $_,
            $_,
            "ParameterName",
            $flags[$_].description
    }
}