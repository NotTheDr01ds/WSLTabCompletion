function Get-WSLArgumentValue ($argumentName, $argumentValuePartial) {
    if ($flags[$argumentName].completionFunction) {
        &$flags[$argumentName].completionFunction -partial $argumentValuePartial
    }
}