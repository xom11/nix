@{
    Description = 'Scheduled task: Kanata keyboard remapper at logon (Run as Admin)'
    Apply = {
        param($Ctx)
        $taskName = 'Kanata'

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

        $kanataLauncher = Join-Path $Ctx.HomeManagerDir 'dotfiles\windows\ahk\launch-kanata.ahk'
        $kanataLauncherDir = Split-Path $kanataLauncher -Parent
        if (-not $ahkExe) {
            Write-Warn "AutoHotkey not found (install via winget: AutoHotkey.AutoHotkey)"
            return
        }
        if (-not (Test-Path $kanataLauncher)) {
            Write-Warn "kanata launcher missing: $kanataLauncher"
            return
        }

        $userId      = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        $description = 'Run Kanata keyboard remapper with elevated privileges'
        $action      = New-ScheduledTaskAction -Execute $ahkExe -Argument "`"$kanataLauncher`"" -WorkingDirectory $kanataLauncherDir
        # No trigger delay. There used to be a flat PT5S here to let VKey register its
        # WH_KEYBOARD_LL hook first, since kanata has to be the newer hook (evkey-monitor.ahk
        # explains why). Measuring the a14 boot of 2026-08-06 showed that guess was nearly a
        # coin flip: VKey's own process did not start until explorer + 4643 ms, so the two were
        # a few hundred milliseconds apart.
        #
        # launch-kanata.ahk now waits on VKey itself (WaitForInputIdle) instead, so the ordering
        # is causal rather than hoped for, and it no longer costs five seconds of raw keyboard
        # at every logon. Do not reintroduce a delay here to "be safe" -- it would only delay
        # the launcher that is already doing the waiting.
        #
        # See services.vkey for the other half: VKey is started by its own scheduled task, which
        # carried the same kind of PT5S guess and is why VKey was late to begin with.
        $trigger     = New-ScheduledTaskTrigger -AtLogOn -User $userId
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
            (Test-TaskUserMatch $existingTask.Triggers[0].UserId $trigger.UserId) -and
            [string]$existingTask.Triggers[0].Delay -eq [string]$trigger.Delay -and
            (Test-TaskUserMatch $existingTask.Principal.UserId $principal.UserId) -and
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
            Write-Skip "scheduled task: $taskName ($ahkExe)"
            return
        }

        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description $description -Force | Out-Null
        Write-OK "scheduled task: $taskName ($ahkExe)"
    }
}
