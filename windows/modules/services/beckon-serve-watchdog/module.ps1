@{
    Description = 'Scheduled task: restart beckon --serve if it dies between logons'
    Apply = {
        param($Ctx)
        $taskName = 'BeckonServeWatchdog'

        $beckonExe = Get-Command beckon.exe -ErrorAction SilentlyContinue
        if (-not $beckonExe) {
            Write-Warn 'beckon.exe not found (scoop install beckon)'
            return
        }

        $config = Join-Path $Ctx.ConfigsDir 'shortcuts\apps.windows.toml'
        if (-not (Test-Path $config)) {
            Write-Warn "shortcuts config missing: $config"
            return
        }

        # KHAC AHKWatchdog, khong can launcher script -- action la CHINH lenh serve;
        # khi service dang song, instance moi bi lock don-instance cua beckon da ra
        # (exit 1) nen watchdog la no-op; khi chet, lan lap ke khoi dong lai. (Cung ly
        # do, chay tay `beckon --serve` tren file that cung vo hai -- lock chan.)
        $userId    = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        $action    = New-ScheduledTaskAction -Execute $beckonExe.Source -Argument "--serve `"$config`""
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
