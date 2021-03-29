#$ModuleDirectory = Split-Path -Path (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent) -Parent
#. ("$ModuleDirectory\private\flags.ps1")
function Get-WSLArgumentName {
    param(
        [String]$ArgumentNamePartial = "",
        $FlagKeysToProcess = $null
    )

    if (!$FlagKeysToProcess) {
        $FlagKeysToProcess = $flags.Keys
    }


    $FlagKeysToProcess | Where-Object { $_ -like "$($argumentNamePartial)*" } | 
        ForEach-Object { 
            if (!$flags[$_].description) { $flags[$_].description = "Null"}
            New-Object -Type System.Management.Automation.CompletionResult -ArgumentList $_,
                $_,
                "ParameterName",
                $flags[$_].description
        }
}