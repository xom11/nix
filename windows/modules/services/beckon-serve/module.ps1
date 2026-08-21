@{
    Description = 'Scheduled task: beckon serve at logon (hotkey host, replaces launch-app.ahk)'
    Apply = {
        param($Ctx)
        $taskName = 'BeckonServe'

        $beckonExe = Get-Command beckon.exe -ErrorAction SilentlyContinue
        if (-not $beckonExe) {
            Write-Warn 'beckon.exe not found (scoop install beckon)'
            return
        }

        $config = Join-Path $Ctx.ConfigsDir 'shortcuts\launch-app.toml'
        if (-not (Test-Path $config)) {
            Write-Warn "shortcuts config missing: $config"
            return
        }

        # No AHK-style startup delay needed: beckon uses RegisterHotKey and
        # installs no hook, so it does not race VKey/kanata for LLHOOK order.
        $log = Join-Path (Join-Path $env:LOCALAPPDATA 'beckon') 'serve.log'
        # --log APPENDS, unlike the old `2>` redirect. Deliberate: RestartOnFailure
        # used to erase the very log explaining the restart.
        #
        # conhost --headless is what keeps a window from appearing. The task must
        # run LogonType=Interactive (RegisterHotKey does not work in session 0), so
        # Windows grants a console, and with Windows Terminal as the default that
        # console arrives as a NEW TAB indistinguishable from a user's own. Closing
        # it sends CTRL_CLOSE_EVENT and kills beckon -- that happened, and hotkeys
        # were dead for four minutes until the watchdog.
        #
        # Five approaches were measured; `powershell -WindowStyle Hidden` still
        # produces the tab, which is the trap. --log alone leaves no window behind
        # but still flashes ~60 ms, because Windows grants the console before
        # main() runs. conhost blocks it from the start.
        #
        # If conhost is ever dropped, the action must point at the real
        # beckon.exe, NOT the scoop shim: the shim survives as a parent process,
        # keeps the console, and defeats beckon's FreeConsole. conhost still waits
        # on the child, so State=Running remains a live-daemon signal. --headless
        # is undocumented; wscript and AutoHotkey Run(..., "Hide") are the fallbacks.
        #
        # Any re-measurement must run INSIDE session 1: window stations are
        # per-session, so enumerating from SSH reports zero windows on a full
        # screen -- a false negative that misled one diagnosis.
        $userId    = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        $action    = New-ScheduledTaskAction -Execute 'conhost.exe' `
            -Argument "--headless `"$($beckonExe.Source)`" serve `"$config`" --log `"$log`""
        $trigger   = New-ScheduledTaskTrigger -AtLogon
        $principal = New-ScheduledTaskPrincipal -UserId $userId -LogonType Interactive -RunLevel Limited
        $settings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
            -StartWhenAvailable -ExecutionTimeLimit 0

        $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        if (Test-ScheduledTaskMatch -Existing $existingTask -Action $action -Trigger $trigger `
                -Principal $principal -Settings $settings) {
            Write-Skip "scheduled task: $taskName"
            return
        }

        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger `
            -Principal $principal -Settings $settings -Force | Out-Null
        Write-OK "scheduled task: $taskName"
    }
}
