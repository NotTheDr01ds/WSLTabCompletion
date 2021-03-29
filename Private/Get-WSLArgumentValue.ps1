#$ModuleDirectory = Split-Path -Path (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent) -Parent
#. ("$ModuleDirectory\private\flags.ps1")
function Get-WSLArgumentValue ($argumentName, $argumentValuePartial) {
    if ($flags[$argumentName].completionFunction) {
        &$flags[$argumentName].completionFunction -partial $argumentValuePartial 
    }
}