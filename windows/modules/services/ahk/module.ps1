@{
    Description = 'Scheduled task: AutoHotkey main.ahk at logon'
    Apply = {
        param($Ctx)
        $taskName = 'AHKrunning'

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
        $ahkFile = Join-Path $Ctx.HomeManagerDir 'dotfiles\windows\ahk\main.ahk'

        if (-not $ahkExe) {
            Write-Warn "AutoHotkey not found (install via winget: AutoHotkey.AutoHotkey)"
            return
        }
        if (-not (Test-Path $ahkFile)) {
            Write-Warn "ahk file missing: $ahkFile"
            return
        }

        # Use full SID-style identity (USERDOMAIN may be 'WORKGROUP' in SSH sessions)
        $userId    = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        $action    = New-ScheduledTaskAction -Execute $ahkExe -Argument "`"$ahkFile`""
        $logonTrigger = New-ScheduledTaskTrigger -AtLogon
        $logonTrigger.Delay = 'PT15S'

        # Watchdog. main.ahk is meant to stay resident, but it was found dead on a machine
        # where the logon run had exited within minutes of boot and nothing brought it back
        # until the next logon.
        #
        # This has to be its own trigger. Hanging a Repetition off the logon trigger does not
        # work: the repetition only starts counting when that trigger next fires, so on an
        # already-logged-on machine it never runs at all -- six minutes of watching the Task
        # Scheduler log after registering it that way produced no events whatsoever. A time
        # trigger anchored in the past is live the moment the task is registered.
        #
        # MultipleInstances is IgnoreNew, so every repeat is a no-op while the script is
        # alive; once it is gone, the next repeat revives it within five minutes.
        # The anchor is a fixed date, not Get-Date -- a moving StartBoundary would differ on
        # every apply run and re-register a task that was already correct.
        $watchdogTrigger = New-ScheduledTaskTrigger -Once -At '2020-01-01T00:00:00' `
            -RepetitionInterval (New-TimeSpan -Minutes 5)

        $triggers = @($logonTrigger, $watchdogTrigger)
        $principal = New-ScheduledTaskPrincipal -UserId $userId -LogonType Interactive -RunLevel Limited
        # ExecutionTimeLimit 0 = no limit. The default the task carried was PT72H, which would
        # have had Task Scheduler kill a healthy script after three days of uptime.
        $settings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
            -StartWhenAvailable -ExecutionTimeLimit 0

        $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        $existingLogon = @($existingTask.Triggers |
            Where-Object { $_.CimClass.CimClassName -eq 'MSFT_TaskLogonTrigger' })
        $existingWatchdog = @($existingTask.Triggers |
            Where-Object { $_.CimClass.CimClassName -eq 'MSFT_TaskTimeTrigger' })

        $taskMatches = $existingTask -and
            @($existingTask.Actions).Count -eq 1 -and
            $existingTask.Actions[0].Execute -eq $action.Execute -and
            $existingTask.Actions[0].Arguments -eq $action.Arguments -and
            @($existingTask.Triggers).Count -eq 2 -and
            $existingLogon.Count -eq 1 -and
            $existingWatchdog.Count -eq 1 -and
            (Test-TaskUserMatch $existingLogon[0].UserId $logonTrigger.UserId) -and
            [string]$existingLogon[0].Delay -eq [string]$logonTrigger.Delay -and
            [string]$existingWatchdog[0].Repetition.Interval -eq [string]$watchdogTrigger.Repetition.Interval -and
            [string]$existingWatchdog[0].Repetition.Duration -eq [string]$watchdogTrigger.Repetition.Duration -and
            (Test-TaskUserMatch $existingTask.Principal.UserId $principal.UserId) -and
            $existingTask.Principal.LogonType -eq $principal.LogonType -and
            $existingTask.Principal.RunLevel -eq $principal.RunLevel -and
            $existingTask.Settings.Enabled -eq $settings.Enabled -and
            $existingTask.Settings.DisallowStartIfOnBatteries -eq $settings.DisallowStartIfOnBatteries -and
            $existingTask.Settings.StopIfGoingOnBatteries -eq $settings.StopIfGoingOnBatteries -and
            $existingTask.Settings.ExecutionTimeLimit -eq $settings.ExecutionTimeLimit -and
            $existingTask.Settings.StartWhenAvailable -eq $settings.StartWhenAvailable
        if ($taskMatches) {
            Write-Skip "scheduled task: $taskName ($ahkExe)"
            return
        }

        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $triggers -Principal $principal -Settings $settings -Force | Out-Null
        Write-OK "scheduled task: $taskName ($ahkExe)"
    }
}
