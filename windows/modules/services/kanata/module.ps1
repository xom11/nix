@{
    Description = 'Scheduled task: Kanata keyboard remapper at logon (Run as Admin)'
    Apply = {
        param($Ctx)
        $taskName = 'Kanata'

        $kanataExe = $null
        $kanataDir = $null
        $kanataDirs = @(
            "$env:USERPROFILE\scoop\apps\kanata\current"
        )
        foreach ($dir in $kanataDirs) {
            $candidate = Join-Path $dir 'kanata_windows_gui_winIOv2_x64.exe'
            if (Test-Path $candidate) {
                $kanataExe = $candidate
                $kanataDir = $dir
                break
            }
        }

        $kanataConfig = Join-Path $Ctx.ConfigsDir 'kanata\kanata_windows.kbd'
        if (-not $kanataExe) {
            Write-Warn "kanata not found (install via scoop: kanata)"
            return
        }
        if (-not (Test-Path $kanataConfig)) {
            Write-Warn "kanata config missing: $kanataConfig"
            return
        }

        $userId      = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        $description = 'Run Kanata keyboard remapper with elevated privileges'
        $action      = New-ScheduledTaskAction -Execute $kanataExe -Argument "-c `"$kanataConfig`"" -WorkingDirectory $kanataDir
        $trigger     = New-ScheduledTaskTrigger -AtLogOn -User $userId
        $trigger.Delay = 'PT30S'
        $principal   = New-ScheduledTaskPrincipal -UserId $userId -LogonType Interactive -RunLevel Highest
        $settings    = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0 -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1) -StartWhenAvailable

        $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        $taskMatches = $existingTask -and
            @($existingTask.Actions).Count -eq 1 -and
            $existingTask.Actions[0].Execute -eq $action.Execute -and
            $existingTask.Actions[0].Arguments -eq $action.Arguments -and
            $existingTask.Actions[0].WorkingDirectory -eq $action.WorkingDirectory -and
            @($existingTask.Triggers).Count -eq 1 -and
            $existingTask.Triggers[0].CimClass.CimClassName -eq $trigger.CimClass.CimClassName -and
            [string]$existingTask.Triggers[0].UserId -eq [string]$trigger.UserId -and
            [string]$existingTask.Triggers[0].Delay -eq [string]$trigger.Delay -and
            $existingTask.Principal.UserId -eq $principal.UserId -and
            $existingTask.Principal.LogonType -eq $principal.LogonType -and
            $existingTask.Principal.RunLevel -eq $principal.RunLevel -and
            $existingTask.Settings.Enabled -eq $settings.Enabled -and
            $existingTask.Settings.DisallowStartIfOnBatteries -eq $settings.DisallowStartIfOnBatteries -and
            $existingTask.Settings.StopIfGoingOnBatteries -eq $settings.StopIfGoingOnBatteries -and
            $existingTask.Settings.ExecutionTimeLimit -eq $settings.ExecutionTimeLimit -and
            $existingTask.Settings.RestartCount -eq $settings.RestartCount -and
            $existingTask.Settings.RestartInterval -eq $settings.RestartInterval -and
            $existingTask.Settings.StartWhenAvailable -eq $settings.StartWhenAvailable -and
            $existingTask.Description -eq $description
        if ($taskMatches) {
            Write-Skip "scheduled task: $taskName ($kanataExe)"
            return
        }

        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description $description -Force | Out-Null
        Write-OK "scheduled task: $taskName ($kanataExe)"
    }
}
