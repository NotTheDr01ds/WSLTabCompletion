#$ModuleDirectory = Split-Path -Path (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent) -Parent
#. ("$ModuleDirectory\private\Get-WSLDistroCompletions.ps1")

$Script:completionLogFile = "./comp.log"
$flags = [ordered]@{}

$flags['~'] = @{
    description = "~: Start in user's home directory. Must be the first argument after the 'wsl' command"
    hasValue = $false
}
$flags['--distribution'] = $flags['-d'] = @{
    description = "-d, --distribution <DistroName>: Run the specified distribution."
    hasValue = $true
    completionFunction = {
        completeDistroName $wordToComplete
    }
    synonyms = @( '-d', '--distribution')
}
$flags['--exec'] = $flags['-e'] = @{
    description = "-e, --exec <CommandLine>: Execute the specified command without using the default Linux shell.  Must be the last flag on the line."
    hasValue = $true
    completionFunction = {}
    synonyms = @( '-e', '--exec')
}
$flags['--user'] = $flags['-u'] = @{
    description = "-u, --user <UserName>: Run as the specified Linux user."
    hasValue = $true
    completionFunction = {
        [Array]$userCompletions = @()
        $userCompletions += "root"
        $userCompletions += if ($env:DefaultWSLUser) { $env:DefaultWSLUser } else { $env:USERNAME }
        return $userCompletions | Where-Object { $_ -match "^$wordToComplete" }
    }
    synonyms = @( '-u', '--user')
}
$flags['--cd'] = @{
    description = "--cd <WindowsPath>: Start in the specified Windows-based directory.  Use \\wsl$\<DistroName> to start in a WSL directory."
    hasValue = $true
    completionFunction = { }
}

$flags['--system'] = @{
    description = "Launches a shell for the WSLg system distribution."
}

# Commands below this line
# Only one "command" may be present per wsl invocation.
# Making this distinction to potentially add logic
# limiting completions on commands

$flags['--list'] = $flags['-l'] = @{
    description = "Lists distributions: <-v/--verbose>, <-q/--quiet>, <--all>, <--running>"
        completionFunction = {
            $listFlags = [ordered]@{}
            $listFlags['--verbose'] = $listFlags['-v'] = "-v/--verbose: Show detailed information about all distributions."
            $listFlags['--quiet'] = $listFlags['-q'] = "-q/--quiet: Only show distribution names."
            $listFlags['--running'] = "--running: List only distributions that are currently running."
            $listFlags['--all'] = "--all: List all distributions, including distributions that are currently being installed or uninstalled."
            $listFlags['--online'] = $listFlags['-o'] = "Displays a list of available distributions for install with 'wsl.exe --install'."

            # Start with all possible --list flags
            $validFlagKeys = $listFlags.Keys
            
            # Get the flags that have already been used
            $usedFlagKeys = $compTokens `
                # Skip the first two tokens, which are the command and the --list flag
                | Select-Object -skip 2 `
                | Where-Object { $_ -ne $wordToComplete }

            # If either --all or --running have already been used,
            # then neither is valid as a completion suggestion
            [Array]$mutuallyExclusiveFlags = @( "--all", "--running" )
            $mutuallyExclusiveFlags | ForEach-Object {
                if ($_ -in $usedFlagKeys) { $validFlagKeys = $validFlagKeys | Where-Object { $_ -notin $mutuallyExclusiveFlags}}
            }
            # If any of these mutually exclusive flags have already been used,
            # then none of them are valid for completion
            [Array]$mutuallyExclusiveFlags = @( "-v", "--verbose", "-q", "--quiet", "--online", "-o")
            $mutuallyExclusiveFlags | ForEach-Object {
                if ($_ -in $usedFlagKeys) { $validFlagKeys = $validFlagKeys | Where-Object { $_ -notin $mutuallyExclusiveFlags}}
            }
            
            # If --online has been used, then no other --list flags are valid
            @( "--online", "-o") | ForEach-Object {
                if ($_ -in $usedFlagKeys) { $validFlagKeys = @() }
            }
            
            # If any other flags have been used, then --online is not valid
            if ($usedFlagKeys.Length -gt 0) {
                $validFlagKeys = $validFlagKeys | Where-Object { $_ -notin @( "--online", "-o") }
            }

            # Match against the partially typed flag
            $validFlagKeys = $validFlagKeys | Where-Object { $_ -match "^$wordToComplete" }
            if ($validFlagKeys) {
                #return $validFlagKeys
                $validFlagKeys | ForEach-Object {
                    New-Object -Type System.Management.Automation.CompletionResult -ArgumentList $_,
                        $_,
                        "ParameterName",
                        $listFlags[$_]
                }
            } else {
                # If we've exhausted all possible --list flags
                # then don't offer any completion suggestions
                return ""
            }
        }
}
$flags['--export'] = @{
    description = "--export <Distro> <FileName.tar>: Exports the distribution to a tar file. The filename can be - for standard output."
    completionFunction = {
        completeDistroName $wordToComplete
    }
}
$flags['--import'] = @{
    description = "--import <Distro> <InstallLocation> <FileName> [Options]: Imports the specified tar file as a new distribution. The filename can be - for standard input."
    completionFunction = {
        switch ($compPattern) {
            # First argument, don't provide any suggestions - must be provided by the user
            'ec ' { "" }
            'ecv' { "" }
            # Second argument must be a directory
            'ecv ' { }
            'ecvv' { }
            # Third argument must be a file
            'ecvv ' { }
            'evvvv' { }
            # Fourth argument can be --version
            'ecvvv ' { "--version" }
            'ecvvvp' { "--version" | Where-Object { $_ -match $wordToComplete}}
            # Fifth argument can be a version, assuming the previous flag is '--version'
            'ecvvvp ' {
                if ($compTokens[5] -eq '--version' ) { @(1,2) }
            }
        }
    }
}
$flags['--set-default'] = $flags['-s'] = @{
    description = "--set-default, -s <Distro>: Sets the distribution as the default."
    completionFunction = {
        completeDistroName $wordToComplete
    }
}
$flags['--set-default-version'] = @{
    description = "--set-default-version <Version>: Changes the default install version for new distributions."
    completionFunction = {
        @(1,2)
    }
}
$flags['--set-version'] = @{
    description = "--set-version <Distro> <Version>: Changes the version of the specified distribution."
    completionFunction = {
        switch ($compPattern) {
            { $_ -in @('ec ','ecv')} { completeDistroName $wordToComplete}
            'ecv ' { @(1,2) }
        }
    }
}
$flags['--terminate'] = $flags['-t'] = @{
    description = "--terminate, -t <Distro>: Terminates the specified distribution."
    completionFunction = {
        completeDistroName $wordToComplete -only_running
    }
}
$flags['--shutdown'] = @{
    description = "Immediately terminates all running distributions and the WSL 2 lightweight utility virtual machine."
}
$flags['--unregister'] = @{
    description = "--unregister <Distro>:  Unregisters the distribution.  WARNING - ALL DATA WILL BE DELETED."
    completionFunction = {
        completeDistroName $wordToComplete
    }
}
$flags['--help'] = @{
    description = "Displays usage information."
}

$flags['--install'] = @{
    description = "Installs WSL or additional distributions."
}

$flags['--debug-shell'] = @{
    description = "Open a WSL2 debug shell in the root namespace for diagnostics purposes."
}

$flags['--event-viewer'] = @{
    description = "Opens the application view of the Windows Event Viewer."
}

$flags['--release-notes'] = @{
    description = "Opens a web browser to view the WSL release notes page."
}

$flags['--version'] = $flags['-v'] = @{
    description = "Display version information for WSL and related components."
}

$flags['--mount'] = @{
    description = "Attaches and mounts a physical or virtual disk in all WSL 2 distributions."
}

$flags['--status'] = @{
    description = "Show the status of Windows Subsystem for Linux."
}

$flags['--update'] = @{
    description = "Update the Windows Subsystem for Linux package."
}

@('--list', '-l', '--export', '--import', '-s', '--set-default-version',
 '--set-default', '--set-version', '--terminate', '-t', '--shutdown',
 '--unregister','--help', '--install', '--debug-shell', '--version', '-v',
 '--release-notes', '--event-viewer', '--mount', '--status', '--update') | ForEach-Object {
     $flags[$_].isCommand = $true
}
