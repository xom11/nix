@{
    Description = 'Scheduled task: AutoHotkey main.ahk at logon (Run as Admin)'
    Apply = {
        param($Ctx)
        $taskName = 'AHKrunning'

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
        $ahkFile = Join-Path $Ctx.HomeManagerDir 'dotfiles\windows\ahk\main.ahk'

        if (-not $ahkExe) {
            Write-Warn "AutoHotkey not found (install via winget: AutoHotkey.AutoHotkey)"
            return
        }
        if (-not (Test-Path $ahkFile)) {
            Write-Warn "ahk file missing: $ahkFile"
            return
        }

        # Use full SID-style identity (USERDOMAIN may be 'WORKGROUP' in SSH sessions)
        $userId    = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        $action    = New-ScheduledTaskAction -Execute $ahkExe -Argument "`"$ahkFile`""
        $trigger   = New-ScheduledTaskTrigger -AtLogon
        $principal = New-ScheduledTaskPrincipal -UserId $userId -LogonType Interactive -RunLevel Highest
        $settings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

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
            $existingTask.Settings.StartWhenAvailable -eq $settings.StartWhenAvailable
        if ($taskMatches) {
            Write-Skip "scheduled task: $taskName ($ahkExe)"
            return
        }

        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
        Write-OK "scheduled task: $taskName ($ahkExe)"
    }
}
