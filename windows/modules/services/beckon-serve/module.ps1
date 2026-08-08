@{
    Description = 'Scheduled task: beckon --serve at logon (hotkey host, replaces launch-app.ahk)'
    Apply = {
        param($Ctx)
        $taskName = 'BeckonServe'

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

        # Khong can delay PT15S kieu AHK: beckon dung RegisterHotKey, khong cai
        # hook nao nen khong dua voi VKey/kanata ve thu tu LLHOOK.
        $userId    = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        $action    = New-ScheduledTaskAction -Execute $beckonExe.Source -Argument "--serve `"$config`""
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
