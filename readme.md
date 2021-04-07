# WSLTabCompletion

A PowerShell module which includes a .Net ArgumentCompleter for the native `wsl.exe` command, used to launch and manage the Windows Subsystem for Linux.

# Limitations

Best results under [PowerShell Core](https://github.com/PowerShell/PowerShell).

Windows PowerShell (the version installed with Windows by default) does not offer completions for arguments starting with `-`.  This makes the feature fairly limited there.  Since Windows PowerShell is deprecated, Microsoft has no plans to fix this. 

### Features ###

* Completes all commands and flags for the current (non-Insider) release of WSL on Windows Build 19042
* Provides tooltip help (at the bottom of the screen) for the offered completions.
* Completes all installed distribution names for the `-d/--distribution`, `--export`, `--terminate`, `--set-default`, `--set-version`, and `--unregister` options.
* Provides additional information on the distributions being offered for completion in the tooltip - Whether or not the instance is running or stopped and the WSL version of the instance.  Also tags the default distribution.
* Only offers running distributions for completion for `--terminate`
* When completing for the `-u/--user` option, offers `root` and the contents of the `$env:defaultWSLUser` environment variable (if it exists)
* Offers the undocumented `~` option for launching the instance in the user's home directory.
* Attempts to only offer completions that make sense given the current command line so far, but there will be corner cases it cannot catch without building a full AST parser for the `wsl` command, which I have no plans to do ;-).
* Falls back to offering the default PowerShell directory/file completion for flags where this makes sense.
* Does not offer any completions when the input must be provided by the user (e.g. the name to provide a new instance when doing an `--import`)

### Installation ###

WSLTabCompletion is published in the [PowerShell Gallery](https://www.powershellgallery.com/packages/WSLTabCompletion), although it is unlisted while in Preview.  To install:

```
Install-Module -Name WSLTabCompletion -RequiredVersion 0.8.0
```

Once installed, test it in a single PowerShell session with:

```
Import-Module WSLTabCompletion
```

Type `wsl ` and then hit <kbd>Tab</kbd> or <kdb>Ctrl</kbd>+<kbd>Space</kbd> to see available completions.  Try completing `wsl -d ` to get a list of installed WSL instances.

Once you have tested it, add the above `Import-Module` line to your PowerShell Core profile (`code $PROFILE` or `notepad $PROFILE`) so that it is available in all instances.

### License ###

This module is provided under the terms of the GPLv3.  You can freely use it on any system you control; you may freely distribute it under the terms of the GPLv3.  To distribute under other terms, please contact the author by filing an [issue](https://github.com/NotTheDr01ds/WSLTabCompletion/issues).

### Implementation notes ###

* The `wsl.exe` command currently appears to output in a (likely [malformed](https://github.com/microsoft/WSL/issues/4456#issuecomment-526807466)) UTF16 character set.  I am using [this](https://github.com/microsoft/WSL/issues/4607#issuecomment-717876058) incredibly helpful workaround by falloutphil.  However, I have not tested this on other locales.  Please file an issue if you run into any problem that appears to be due to character-encoding (or any other problem, of course).