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

        # Logon is the only trigger here. Reviving a script that died mid-uptime is the
        # services.ahk-watchdog task's job, and it has to be a separate task: a timed repeat
        # hung off this one relied on MultipleInstances=IgnoreNew to stay a no-op while the
        # script was alive, which stops being true the moment Reload() (Tab+r) replaces the
        # process Task Scheduler was tracking. See that module for the full account.
        $triggers = @($logonTrigger)
        $principal = New-ScheduledTaskPrincipal -UserId $userId -LogonType Interactive -RunLevel Limited
        # ExecutionTimeLimit 0 = no limit. The default the task carried was PT72H, which would
        # have had Task Scheduler kill a healthy script after three days of uptime.
        $settings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
            -StartWhenAvailable -ExecutionTimeLimit 0

        $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        $existingLogon = @($existingTask.Triggers |
            Where-Object { $_.CimClass.CimClassName -eq 'MSFT_TaskLogonTrigger' })

        # Count -eq 1 is load-bearing on machines that ran the old two-trigger version: it is
        # what notices the leftover timed repeat and re-registers the task without it.
        $taskMatches = $existingTask -and
            @($existingTask.Actions).Count -eq 1 -and
            $existingTask.Actions[0].Execute -eq $action.Execute -and
            $existingTask.Actions[0].Arguments -eq $action.Arguments -and
            @($existingTask.Triggers).Count -eq 1 -and
            $existingLogon.Count -eq 1 -and
            (Test-TaskUserMatch $existingLogon[0].UserId $logonTrigger.UserId) -and
            [string]$existingLogon[0].Delay -eq [string]$logonTrigger.Delay -and
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
