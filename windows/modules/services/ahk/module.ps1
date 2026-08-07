@{
    Description = 'Scheduled task: AutoHotkey main.ahk at logon'
    Apply = {
        param($Ctx)
        $taskName = 'AHKrunning'

        $ahkExe = Get-AutoHotkeyExe
        if (-not $ahkExe) {
            Write-Warn "AutoHotkey not found (install via winget: AutoHotkey.AutoHotkey)"
            return
        }

        $ahkFile = Join-Path $Ctx.HomeManagerDir 'dotfiles\windows\ahk\main.ahk'
        if (-not (Test-Path $ahkFile)) {
            Write-Warn "ahk file missing: $ahkFile"
            return
        }

        # Use full SID-style identity (USERDOMAIN may be 'WORKGROUP' in SSH sessions)
        $userId    = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        $action    = New-ScheduledTaskAction -Execute $ahkExe -Argument "`"$ahkFile`""
        $logonTrigger = New-ScheduledTaskTrigger -AtLogon
        # PT15S is the one delay on this path that is deliberate, and it is not about giving
        # AutoHotkey time to start -- it is about main.ahk starting AFTER VKey.
        #
        # evkey-monitor.ahk seeds __vk_wasRunning from whatever it sees on its first poll. Start
        # main.ahk before VKey and that seed is `false`, so VKey appearing a moment later looks
        # exactly like a VKey restart and fires a `schtasks /run Kanata` nobody needed -- a
        # keystroke gap at every single logon, to fix an ordering the kanata launcher was already
        # handling on its own.
        #
        # Measured on the a14 boot of 2026-08-07: \VKey started at 19:18:09.026 and \AHKrunning
        # at 19:18:24.5, so the seed was read with VKey already up. Unlike the PT5S delays this
        # repo removed from \Kanata and \VKey, nothing here is racing a hook registration, so
        # there is no causal signal to wait on instead -- the margin is the mechanism.
        $logonTrigger.Delay = 'PT15S'

        # Logon is the only trigger here. Reviving a script that died mid-uptime is the
        # services.ahk-watchdog task's job, and it has to be a separate task: a timed repeat
        # hung off this one relied on MultipleInstances=IgnoreNew to stay a no-op while the
        # script was alive, which stops being true the moment Reload() (Tab+r) replaces the
        # process Task Scheduler was tracking. See that module for the full account.
        #
        # Test-ScheduledTaskMatch requires exactly one trigger, which is what notices a machine
        # still carrying the old two-trigger shape and re-registers it without the leftover.
        $triggers = @($logonTrigger)
        $principal = New-ScheduledTaskPrincipal -UserId $userId -LogonType Interactive -RunLevel Limited
        # ExecutionTimeLimit 0 = no limit. The default the task carried was PT72H, which would
        # have had Task Scheduler kill a healthy script after three days of uptime.
        $settings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
            -StartWhenAvailable -ExecutionTimeLimit 0

        $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        if (Test-ScheduledTaskMatch -Existing $existingTask -Action $action -Trigger $logonTrigger `
                -Principal $principal -Settings $settings) {
            Write-Skip "scheduled task: $taskName ($ahkExe)"
            return
        }

        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $triggers -Principal $principal -Settings $settings -Force | Out-Null
        Write-OK "scheduled task: $taskName ($ahkExe)"
    }
}
