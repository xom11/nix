@{
    Description = 'Scheduled task: bring main.ahk back if it dies between logons'
    Apply = {
        param($Ctx)
        $taskName = 'AHKWatchdog'

        # AHKrunning only has a logon trigger and this machine logs on rarely -- two logons in
        # five days when that was measured -- so a main.ahk that dies mid-uptime stays dead for
        # days, taking every hotkey with it.
        #
        # This is a second task rather than another trigger on AHKrunning, and not only because
        # the actions differ. The repetition did live on AHKrunning once, relying on
        # MultipleInstances=IgnoreNew to skip the repeat while the script was alive. That only
        # holds while Task Scheduler still owns the process: Reload() (Tab+r) makes the running
        # copy exit 0 and spawn a replacement the scheduler knows nothing about, so it recorded
        # the instance as completed and the next repeat started a second main.ahk, whose
        # #SingleInstance Force killed the freshly reloaded one. Here the launcher decides from
        # the desktop whether main.ahk is alive, which no longer depends on who started it.

        $ahkExe = Get-AutoHotkeyExe
        if (-not $ahkExe) {
            Write-Warn "AutoHotkey not found (install via winget: AutoHotkey.AutoHotkey)"
            return
        }

        $launcher = Join-Path $Ctx.HomeManagerDir 'dotfiles\windows\ahk\launch-ahk.ahk'
        if (-not (Test-Path $launcher)) {
            Write-Warn "ahk launcher missing: $launcher"
            return
        }

        $userId      = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        $description = 'Start main.ahk when it is not running; leaves a healthy instance alone'
        $action      = New-ScheduledTaskAction -Execute $ahkExe -Argument "`"$launcher`" --if-missing"
        # Anchored in the past so the repetition is live the moment the task is registered,
        # instead of waiting for a logon that may be days away. A fixed date, not Get-Date --
        # a moving StartBoundary would differ on every apply run and re-register a task that
        # was already correct.
        $trigger     = New-ScheduledTaskTrigger -Once -At '2020-01-01T00:00:00' `
            -RepetitionInterval (New-TimeSpan -Minutes 5)
        # Limited, unlike the kanata watchdog: main.ahk has to stay an unelevated process (it
        # would otherwise be unable to talk to unelevated windows), and the script the launcher
        # starts inherits the launcher's level.
        $principal   = New-ScheduledTaskPrincipal -UserId $userId -LogonType Interactive -RunLevel Limited
        $settings    = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
            -StartWhenAvailable -ExecutionTimeLimit 0

        $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        if (Test-ScheduledTaskMatch -Existing $existingTask -Action $action -Trigger $trigger `
                -Principal $principal -Settings $settings -Description $description) {
            Write-Skip "scheduled task: $taskName ($ahkExe)"
            return
        }

        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger `
            -Principal $principal -Settings $settings -Description $description -Force | Out-Null
        Write-OK "scheduled task: $taskName ($ahkExe)"
    }
}
