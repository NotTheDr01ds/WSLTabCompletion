#$ModuleDirectory = Split-Path -Path (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent) -Parent
#. ("$ModuleDirectory\private\flags.ps1")
function Get-WSLArgumentName {
    param(
        [String]$ArgumentNamePartial = "",
        [Switch]$OnlyFlags,
        [Array]$Tokens
    )

    [Array]$validArguments = $flags.Keys | Where-Object { $_ -match $ArgumentNamePartial }
    
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