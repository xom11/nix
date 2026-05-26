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
        $taskMatches = $existingTask -and
            @($existingTask.Actions).Count -eq 1 -and
            $existingTask.Actions[0].Execute -eq $action.Execute -and
            $existingTask.Actions[0].Arguments -eq $action.Arguments -and
            @($existingTask.Triggers).Count -eq 1 -and
            $existingTask.Triggers[0].CimClass.CimClassName -eq $trigger.CimClass.CimClassName -and
            [string]$existingTask.Triggers[0].UserId -eq [string]$trigger.UserId -and
            $existingTask.Principal.UserId -eq $principal.UserId -and
            $existingTask.Principal.LogonType -eq $principal.LogonType -and
            $existingTask.Principal.RunLevel -eq $principal.RunLevel -and
            $existingTask.Settings.Enabled -eq $settings.Enabled -and
            $existingTask.Settings.DisallowStartIfOnBatteries -eq $settings.DisallowStartIfOnBatteries -and
            $existingTask.Settings.StopIfGoingOnBatteries -eq $settings.StopIfGoingOnBatteries -and
            $existingTask.Settings.ExecutionTimeLimit -eq $settings.ExecutionTimeLimit -and
            $existingTask.Settings.RestartCount -eq $settings.RestartCount -and
            $existingTask.Settings.RestartInterval -eq $settings.RestartInterval -and
            $existingTask.Description -eq $description
        if ($taskMatches) {
            Write-Skip "scheduled task: $taskName ($syncthingExe)"
            return
        }

        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description $description -Force | Out-Null
        Write-OK "scheduled task: $taskName ($syncthingExe)"
    }
}
