@{
    Description = 'Scheduled task: Kanata keyboard remapper at logon (Run as Admin)'
    Apply = {
        param($Ctx)
        $taskName = 'Kanata'

        $ahkExe = Get-AutoHotkeyExe
        if (-not $ahkExe) {
            Write-Warn "AutoHotkey not found (install via winget: AutoHotkey.AutoHotkey)"
            return
        }

        $kanataLauncher = Join-Path $Ctx.HomeManagerDir 'dotfiles\windows\ahk\launch-kanata.ahk'
        if (-not (Test-Path $kanataLauncher)) {
            Write-Warn "kanata launcher missing: $kanataLauncher"
            return
        }
        $kanataLauncherDir = Split-Path $kanataLauncher -Parent

        $userId      = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        $description = 'Run Kanata keyboard remapper with elevated privileges'
        $action      = New-ScheduledTaskAction -Execute $ahkExe -Argument "`"$kanataLauncher`"" -WorkingDirectory $kanataLauncherDir
        # No trigger delay. There used to be a flat PT5S here to let VKey register its
        # WH_KEYBOARD_LL hook first, since kanata has to be the newer hook (evkey-monitor.ahk
        # explains why). Measuring the a14 boot of 2026-08-06 showed that guess was nearly a
        # coin flip: VKey's own process did not start until explorer + 4643 ms, so the two were
        # a few hundred milliseconds apart.
        #
        # launch-kanata.ahk now waits on VKey itself (WaitForInputIdle) instead, so the ordering
        # is causal rather than hoped for, and it no longer costs five seconds of raw keyboard
        # at every logon. Do not reintroduce a delay here to "be safe" -- it would only delay
        # the launcher that is already doing the waiting.
        #
        # See services.vkey for the other half: VKey is started by its own scheduled task, which
        # carried the same kind of PT5S guess and is why VKey was late to begin with.
        $trigger     = New-ScheduledTaskTrigger -AtLogOn -User $userId
        $principal   = New-ScheduledTaskPrincipal -UserId $userId -LogonType Interactive -RunLevel Highest
        # No restart-on-failure, unlike the shape this task carried until 2026-08-07. Task
        # Scheduler only restarts an action that exits non-zero, and this action is the AHK
        # launcher, which exits 0 the moment it has spawned kanata -- so on the normal path the
        # setting never fired. The one path it did cover, a missing kanata build, is already
        # swept every five minutes by services.kanata-watchdog. Three tasks here carry no
        # restart policy; this one carrying it was an inconsistency, not a safety net.
        $settings    = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0 -StartWhenAvailable

        $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        if (Test-ScheduledTaskMatch -Existing $existingTask -Action $action -Trigger $trigger `
                -Principal $principal -Settings $settings -Description $description) {
            Write-Skip "scheduled task: $taskName ($ahkExe)"
            return
        }

        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description $description -Force | Out-Null
        Write-OK "scheduled task: $taskName ($ahkExe)"
    }
}
