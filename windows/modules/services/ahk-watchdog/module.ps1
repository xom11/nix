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

        $ahkExe = $null
        foreach ($name in 'AutoHotkey64','AutoHotkey','AutoHotkey32') {
            $cmd = Get-Command $name -ErrorAction SilentlyContinue
            if ($cmd) { $ahkExe = $cmd.Source; break }
        }
        if (-not $ahkExe) {
            $candidates = @(
                "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe"
                "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey.exe"
                "$env:ProgramFiles\AutoHotkey\AutoHotkey.exe"
                "${env:ProgramFiles(x86)}\AutoHotkey\AutoHotkey.exe"
            )
            $ahkExe = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
        }

        $launcher = Join-Path $Ctx.HomeManagerDir 'dotfiles\windows\ahk\launch-ahk.ahk'
        if (-not $ahkExe) {
            Write-Warn "AutoHotkey not found (install via winget: AutoHotkey.AutoHotkey)"
            return
        }
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
        # Limited, unlike KanataWatchdog: main.ahk has to stay an unelevated process (it would
        # otherwise be unable to talk to unelevated windows), and the script the launcher starts
        # inherits the launcher's level.
        $principal   = New-ScheduledTaskPrincipal -UserId $userId -LogonType Interactive -RunLevel Limited
        $settings    = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
            -StartWhenAvailable -ExecutionTimeLimit 0

        $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        # StartBoundary is deliberately not compared: it is given without a timezone and read
        # back with one, so comparing it would never match.
        $taskMatches = $existingTask -and
            @($existingTask.Actions).Count -eq 1 -and
            $existingTask.Actions[0].Execute -eq $action.Execute -and
            $existingTask.Actions[0].Arguments -eq $action.Arguments -and
            @($existingTask.Triggers).Count -eq 1 -and
            $existingTask.Triggers[0].CimClass.CimClassName -eq $trigger.CimClass.CimClassName -and
            [string]$existingTask.Triggers[0].Repetition.Interval -eq [string]$trigger.Repetition.Interval -and
            [string]$existingTask.Triggers[0].Repetition.Duration -eq [string]$trigger.Repetition.Duration -and
            (Test-TaskUserMatch $existingTask.Principal.UserId $principal.UserId) -and
            $existingTask.Principal.LogonType -eq $principal.LogonType -and
            $existingTask.Principal.RunLevel -eq $principal.RunLevel -and
            $existingTask.Settings.Enabled -eq $settings.Enabled -and
            $existingTask.Settings.DisallowStartIfOnBatteries -eq $settings.DisallowStartIfOnBatteries -and
            $existingTask.Settings.StopIfGoingOnBatteries -eq $settings.StopIfGoingOnBatteries -and
            $existingTask.Settings.ExecutionTimeLimit -eq $settings.ExecutionTimeLimit -and
            $existingTask.Settings.StartWhenAvailable -eq $settings.StartWhenAvailable -and
            $existingTask.Description -eq $description
        if ($taskMatches) {
            Write-Skip "scheduled task: $taskName ($ahkExe)"
            return
        }

        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger `
            -Principal $principal -Settings $settings -Description $description -Force | Out-Null
        Write-OK "scheduled task: $taskName ($ahkExe)"
    }
}
