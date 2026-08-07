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
    # is named after the build (kanata_windows_tty_winIOv2_<arch>) and kept the keyboard
    # hooked. The wildcard is deliberate -- the name ends in the CPU architecture, so a
    # literal would go stale the moment the machine changes build.
    $running = Get-Process -Name 'kanata*' -ErrorAction SilentlyContinue
    if (-not $running) {
        Write-Host "kanata is not running."
        return
    }
    $running | Stop-Process -Force
    Write-Host ("kanata stopped ({0})." -f (($running.ProcessName | Sort-Object -Unique) -join ', '))
}
function py { python $args }
# The other hosts get `update` as a home-manager shell alias (base/macos, base/nixos,
# base/ubuntu); this is the Windows half of the same command. Pull the repo, then converge the
# machine onto it. Package upgrades stay out on purpose -- apply.ps1 only installs what is
# missing, and `scoop update` / `winget upgrade` remain manual.
function update {
    $repo  = Join-Path $env:USERPROFILE '.nix'
    $apply = Join-Path $repo 'windows\apply.ps1'

    if (-not (Test-Path $apply)) {
        Write-Host "ERROR: $apply not found." -ForegroundColor Red
        return
    }

    # Unelevated on purpose: pulling under an admin token leaves the new files owned by
    # Administrators, and plain git afterwards trips over its own dubious-ownership check.
    # --ff-only rather than a bare pull -- config gets edited on this machine too, and a
    # diverged history should stop and say so instead of growing a merge commit.
    git -C $repo pull --ff-only
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: git pull failed - not applying." -ForegroundColor Red
        return
    }

    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if ($isAdmin) {
        # Already elevated: this is the SSH path, since sshd logs in as a local admin.
        & $apply -NoElevate -NoWait
    } elseif (Get-Command gsudo -ErrorAction SilentlyContinue) {
        # gsudo shares this console, so the log lands here and the exit code comes back --
        # unlike -Verb RunAs, which would put both in a window that closes on its own.
        gsudo pwsh -NoProfile -ExecutionPolicy Bypass -File $apply -NoElevate -NoWait
    } else {
        Write-Host "gsudo not found - falling back to the UAC prompt in apply.ps1 (new window)." -ForegroundColor Yellow
        & $apply
    }
}
