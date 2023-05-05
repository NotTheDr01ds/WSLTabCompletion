function completeDistroName {
    param(
        [String]$distroNamePartial,
        [Switch]$only_running
    )

    $console = ([console]::OutputEncoding)
    [console]::OutputEncoding = New-Object System.Text.UnicodeEncoding
    $distroTextArray = (wsl -l -v) | Where-Object { $_ -ne "" } | Select-Object -Skip 1
    if ($only_running.IsPresent) {
        $distroTextArray = $distroTextArray | Select-String -Pattern '^(\*)?\s+(.*?)\s+(Running)\s+(1|2)'
    }
    [console]::OutputEncoding = $console

    $distroFullArray = @()
    $distroTextArray | ForEach-Object {
        # (Default) (DistroName) (Running or Stopped) (WSL Version)
        $m = $_ | Select-String -Pattern '^(\*)?\s+(.*?)\s+(Running|Stopped)\s+(1|2)'
        $distro = @{
            name = $m.Matches.Groups[2].Value
            isDefault = if ( $m.Matches.Groups[1].Value -eq "*") { $true } else { $false }
            state = $m.Matches.Groups[3].Value
            version = $m.Matches.Groups[4].Value
        }
        $distro.displayName = $distro.name
        if ($distro.isDefault) {
            $distro.displayName = $distro.name + " (Default)"
        }
        $distro.displayName = $distro.displayName + " (WSL$($distro.version))"
        $distro.tooltip = $distro.displayName + " - $($distro.state)"

        $distroFullArray += $distro
    }
    $distroArray = $distroFullArray
    if ($distroNamePartial -ne "") {
        $distroArray = $distroArray | Where-Object { $_.name -imatch "$distroNamePartial"}
    }
    if ($only_running.IsPresent) {
        $distroArray = $distroArray | Where-Object { $_.state -eq "Running" }
    }
    $distroArray | ForEach-Object {
        New-Object -Type System.Management.Automation.CompletionResult -ArgumentList $_.name,
            $_.displayName,
            "ParameterValue",
            $_.tooltip
    }
}