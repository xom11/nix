@{
    Description = 'Scheduled task: Syncthing headless at logon (Web UI http://localhost:8384)'
    Apply = {
        param($Ctx)
        $taskName     = 'Syncthing'
        $syncthingExe = (Get-Command syncthing -ErrorAction SilentlyContinue).Source
        if (-not $syncthingExe) {
            $candidates = @(
                "$env:ProgramFiles\Syncthing\syncthing.exe"
                "$env:LOCALAPPDATA\Programs\Syncthing\syncthing.exe"
            )
            $syncthingExe = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
        }
        if (-not $syncthingExe) {
            Write-Warn "syncthing not found (install via winget: SyncthingFOSS.Syncthing)"
            return
        }

        $userId      = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        $description = 'Run Syncthing continuously in background'
        $action    = New-ScheduledTaskAction -Execute $syncthingExe -Argument '--no-browser --no-console'
        $trigger   = New-ScheduledTaskTrigger -AtLogOn -User $userId
        $settings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0 -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)
        $principal = New-ScheduledTaskPrincipal -UserId $userId -LogonType Interactive -RunLevel Limited

        $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        if (Test-ScheduledTaskMatch -Existing $existingTask -Action $action -Trigger $trigger `
                -Principal $principal -Settings $settings -Description $description) {
            Write-Skip "scheduled task: $taskName ($syncthingExe)"
            return
        }

        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description $description -Force | Out-Null
        Write-OK "scheduled task: $taskName ($syncthingExe)"
    }
}
