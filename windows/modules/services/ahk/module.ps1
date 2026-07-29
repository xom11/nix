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
        $trigger   = New-ScheduledTaskTrigger -AtLogon
        $trigger.Delay = 'PT15S'
        # Repeat the trigger forever as a watchdog. main.ahk is meant to stay resident, but it
        # was found dead on a machine where the logon run had exited within minutes of boot and
        # nothing brought it back until the next logon. MultipleInstances is IgnoreNew, so while
        # the script is alive every repeat is a no-op; once it is gone, the next one revives it.
        $trigger.Repetition = (New-ScheduledTaskTrigger -Once -At (Get-Date) `
            -RepetitionInterval (New-TimeSpan -Minutes 5)).Repetition
        $principal = New-ScheduledTaskPrincipal -UserId $userId -LogonType Interactive -RunLevel Limited
        # ExecutionTimeLimit 0 = no limit. The default the task carried was PT72H, which would
        # have had Task Scheduler kill a healthy script after three days of uptime.
        $settings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
            -StartWhenAvailable -ExecutionTimeLimit 0

        $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        $taskMatches = $existingTask -and
            @($existingTask.Actions).Count -eq 1 -and
            $existingTask.Actions[0].Execute -eq $action.Execute -and
            $existingTask.Actions[0].Arguments -eq $action.Arguments -and
            @($existingTask.Triggers).Count -eq 1 -and
            $existingTask.Triggers[0].CimClass.CimClassName -eq $trigger.CimClass.CimClassName -and
            (Test-TaskUserMatch $existingTask.Triggers[0].UserId $trigger.UserId) -and
            [string]$existingTask.Triggers[0].Delay -eq [string]$trigger.Delay -and
            [string]$existingTask.Triggers[0].Repetition.Interval -eq [string]$trigger.Repetition.Interval -and
            [string]$existingTask.Triggers[0].Repetition.Duration -eq [string]$trigger.Repetition.Duration -and
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

        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
        Write-OK "scheduled task: $taskName ($ahkExe)"
    }
}
