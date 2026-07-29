$conflicts = @("gc", "gl", "gp", "gu")
foreach ($alias in $conflicts) {
    if (Test-Path "alias:$alias") {
        Remove-Item "alias:$alias" -Force
    }
}
function v { nvim.exe  $args}
function lzg { lazygit }
function lzd { lazydocker }
function ff { fastfetch }
function aic {claude --verbose --allow-dangerously-skip-permissions }
function ga { git add $args }
function gc {
    if ($args.Count -eq 0) {
        Write-Warning "Commit message is required."
    }
    else {
        $message = $args -join " "
        git commit -m "$message"
    }
}
function gp { git push $args }
function gst { git status $args }
function gl { git pull $args }
function gu {
    if ($args.Count -eq 0) {
        $commit_msg = "update"
    } else {
        $commit_msg = $args -join " "
    }

    git pull && git add . && git commit -m "$commit_msg" && git push
}
function gcl { git clone $args }
function glog {
    git log --graph --oneline --decorate --all
}
# Kanata belongs to an elevated scheduled task (windows/modules/services/kanata); running the
# task is the restart, and launch-kanata.ahk kills the old process before starting a new one.
# Starting kanata.exe by hand here gave an unelevated instance instead.
function kr { schtasks /run /tn "Kanata" | Out-Null }
function ks {
    # `Stop-Process -Name kanata` only ever hit the scoop shim; the binary the shim launches
    # is named after the build (kanata_windows_tty_winIOv2_x64) and kept the keyboard hooked.
    $running = Get-Process -Name 'kanata*' -ErrorAction SilentlyContinue
    if (-not $running) {
        Write-Host "kanata is not running."
        return
    }
    $running | Stop-Process -Force
    Write-Host ("kanata stopped ({0})." -f (($running.ProcessName | Sort-Object -Unique) -join ', '))
}
function py { python $args }
