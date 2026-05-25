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

        $action    = New-ScheduledTaskAction -Execute $syncthingExe -Argument '--no-browser --no-console'
        $trigger   = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
        $settings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0 -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)
        $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description 'Run Syncthing continuously in background' -Force | Out-Null
        Write-OK "scheduled task: $taskName ($syncthingExe)"
    }
}
