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
        param($partial)
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
        "root"
        if ($env:defaultWSLUser) { $env:defaultWSLUser }
    }
    synonyms = @( '-u', '--user')
}
$flags['--cd'] = @{
    description = "--cd <WindowsPath>: Start in the specified Windows-based directory.  Use \\wsl$\<DistroName> to start in a WSL directory."
    hasValue = $true
    completionFunction = { } 
}

# Commands below this line
# Only one "command" may be present per wsl invocation.  
# Making this distinction to potentially add logic
# limiting completions on commands

$flags['--list'] = $flags['-l'] = @{
    description = "Lists distributions: <-v/--verbose>, <-q/--quiet>, <--all>, <--running>"
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
            'ecvvvp' { @("--version") | Where-Object { $_ -match $wordToComplete}}
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
$flags['--terminate'] = @{
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
@('--list', '-l', '--export', '--import', '-s', '--set-default-version',
 '--set-default', '--set-version', '--terminate', '--shutdown', 
 '--unregister','--help') | ForEach-Object { 
     $flags[$_].isCommand = $true 
}