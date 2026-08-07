@{
    Description = 'Scheduled task: bring Kanata back if it dies between logons'
    Apply = {
        param($Ctx)
        $taskName = 'KanataWatchdog'

        # The Kanata task itself only has a logon trigger, and this machine logs on rarely --
        # two logons in five days when this was measured. So a kanata that dies mid-uptime
        # stays dead for days, taking the keyboard remapping with it.
        #
        # This is a second task rather than another trigger on the Kanata task because the two
        # actions differ: Kanata force-restarts (that is what evkey-monitor.ahk needs after
        # VKey comes back), while this one must leave a healthy kanata alone. One task has one
        # action, so the split is forced -- and evkey-monitor runs unelevated, so it cannot kill
        # the elevated kanata itself and has to go through a task that can.

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
        $description = 'Start Kanata when it is not running; leaves a healthy instance alone'
        $action      = New-ScheduledTaskAction -Execute $ahkExe `
            -Argument "`"$kanataLauncher`" --if-missing" -WorkingDirectory $kanataLauncherDir
        # Anchored in the past so the repetition is live the moment the task is registered,
        # instead of waiting for a logon that may be days away. A fixed date, not Get-Date --
        # a moving StartBoundary would differ on every apply run and re-register a task that
        # was already correct.
        $trigger     = New-ScheduledTaskTrigger -Once -At '2020-01-01T00:00:00' `
            -RepetitionInterval (New-TimeSpan -Minutes 5)
        # Highest: kanata needs admin to install its keyboard hook.
        $principal   = New-ScheduledTaskPrincipal -UserId $userId -LogonType Interactive -RunLevel Highest
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
