Function Register-WSLArgumentCompleter {
    . "$PSScriptRoot\..\Private\completerScriptBlock.ps1"
    Register-ArgumentCompleter -CommandName "wsl" `
        -ScriptBlock $Script:argCompFunction `
        -Native
}
