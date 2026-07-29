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
        # VKey comes back), while this one must leave a healthy kanata alone.

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

        $kanataLauncher = Join-Path $Ctx.HomeManagerDir 'dotfiles\windows\ahk\launch-kanata.ahk'
        $kanataLauncherDir = Split-Path $kanataLauncher -Parent
        if (-not $ahkExe) {
            Write-Warn "AutoHotkey not found (install via winget: AutoHotkey.AutoHotkey)"
            return
        }
        if (-not (Test-Path $kanataLauncher)) {
            Write-Warn "kanata launcher missing: $kanataLauncher"
            return
        }

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
        # StartBoundary is deliberately not compared: it is given without a timezone and read
        # back with one, so comparing it would never match.
        $taskMatches = $existingTask -and
            @($existingTask.Actions).Count -eq 1 -and
            $existingTask.Actions[0].Execute -eq $action.Execute -and
            $existingTask.Actions[0].Arguments -eq $action.Arguments -and
            $existingTask.Actions[0].WorkingDirectory -eq $action.WorkingDirectory -and
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
