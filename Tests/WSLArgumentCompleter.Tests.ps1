
BeforeAll {
    $Public  = @( Get-ChildItem -Path $PSScriptRoot\..\Public\*.ps1 -ErrorAction SilentlyContinue )
    $Private = @( Get-ChildItem -Path $PSScriptRoot\..\Private\*.ps1 -ErrorAction SilentlyContinue )

    Foreach($import in @($Public + $Private))
    {
        Try
        {
            . $import.fullname
        }
        Catch
        {
            Write-Error -Message "Failed to import function $($import.fullname): $_"
        }
    }
    function Get-CommandAst {
        [OutputType([System.Management.Automation.Language.CommandAst])]
        param ([String]$CommandLine)

        $tokens = $Errors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($CommandLine,[ref]$Tokens,[ref]$Errors)
        return $ast.Find({$args[0] -is [System.Management.Automation.Language.CommandAst]}, $true)
    }
}

Describe 'Get-CompletionPattern for <CommandLine>' -ForEach @(
    @{ CommandLine = "wsl -d Ubuntu "; ExpectedResult = "efv " }
    @{ CommandLine = "wsl ~ -"; ExpectedResult = "efp" }
    @{ CommandLine = "wsl --list "; ExpectedResult = "ec " }
    @{ CommandLine = "wsl --list --ve"; ExpectedResult = "ecp" }
) {
    It 'Completion Pattern should be "<ExpectedResult>"' {
        $commandAst = Get-CommandAst $commandLine
        [String[]]$compTokens = $commandAst.CommandElements.ForEach({$_.Extent.Text})
        if ($CommandLine[-1] -eq " ") {
            $wordToComplete = ""
        } else {
            $wordToComplete = $compTokens[-1]
        }
        $completionPattern = Get-CompletionPattern -Tokens $compTokens -WordToComplete $wordToComplete
        
        $completionPattern | Should -Be $ExpectedResult
    }
}

#$a = & $Script:argCompFunction "" $commandAst $commandAst.Extent.EndOffset