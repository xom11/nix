@{
    Description = 'Scheduled task: restart beckon serve if it dies between logons'
    Apply = {
        param($Ctx)
        $taskName = 'BeckonServeWatchdog'

        $beckonExe = Get-Command beckon.exe -ErrorAction SilentlyContinue
        if (-not $beckonExe) {
            Write-Warn 'beckon.exe not found (scoop install beckon)'
            return
        }

        $config = Join-Path $Ctx.ConfigsDir 'shortcuts\apps.shared.toml'
        if (-not (Test-Path $config)) {
            Write-Warn "shortcuts config missing: $config"
            return
        }

        # Unlike AHKWatchdog this needs no launcher script -- the action IS the
        # serve command. While serve is alive the new instance loses beckon's
        # single-instance lock, so the probe is a no-op; when it dies, the next
        # tick restarts it.
        #
        # LastTaskResult is MEANINGLESS here since conhost went in front: Task
        # Scheduler sees conhost's code, always 0x0, not beckon's. It used to be
        # 0x1 for "lock refused" = healthy. The only evidence left is the log
        # below -- read its CONTENT, and its mtime to confirm probes still run.
        $log = Join-Path (Join-Path $env:LOCALAPPDATA 'beckon') 'serve-watchdog.log'
        # A separate log from the main task: while serve is alive this holds only
        # lock-refused lines, which is the HEALTHY signal.
        #
        # --log APPENDS and does not rotate: at one probe per 5 minutes that is
        # ~30 KB/day. If it becomes a nuisance, delete it while serve is stopped,
        # or restore an overwriting redirect for THIS task only -- not the main
        # one, where overwriting once destroyed the evidence. Read with -Tail.
        #
        # conhost --headless is explained in full in the beckon-serve module.
        # Short version: without it each run spawns a new Windows Terminal tab,
        # and this task runs every 5 minutes, so it is the biggest source of them.
        # `powershell -WindowStyle Hidden` does NOT help -- measured.
        $userId    = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        $action    = New-ScheduledTaskAction -Execute 'conhost.exe' `
            -Argument "--headless `"$($beckonExe.Source)`" serve `"$config`" --log `"$log`""
        $trigger   = New-ScheduledTaskTrigger -Once -At '2020-01-01T00:00:00' `
            -RepetitionInterval (New-TimeSpan -Minutes 5)
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
