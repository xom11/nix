@{
    Description = 'Scheduled task: tongue agent — bridges session 0 (SSH) to the desktop session'
    Apply       = {
        param($Ctx)
        $taskName = 'TongueAgent'

        # `.local\bin` deliberately, not a scoop shim: tongue on Windows is installed
        # out of band (see CLAUDE.md, "Windows — tongue"), and that directory precedes
        # scoop on PATH here anyway.
        $exe = Join-Path $env:USERPROFILE '.local\bin\tongue.exe'
        if (-not (Test-Path $exe)) {
            Write-Warn "tongue.exe not found at $exe"
            return
        }
        # The agent subcommand only exists from the named-pipe build onward. An older
        # binary would take `agent` as an unknown subcommand, exit 2 immediately, and
        # the task would sit at State=Ready looking perfectly healthy -- so check the
        # surface rather than trusting the path.
        if (-not (& $exe --help 2>&1 | Select-String -SimpleMatch 'agent' -Quiet)) {
            Write-Warn 'tongue.exe has no `agent` subcommand -- copy a newer build to .local\bin'
            return
        }

        # Why this task exists at all: Windows OpenSSH is a service, so the shell it
        # spawns lands in SESSION 0. Both mechanisms tongue drives VKey with are
        # per-session -- window station (FindWindow) and the `Local\` namespace
        # (OpenFileMapping) -- so `ssh a14 tongue vi` cannot reach the user's VKey and
        # refuses outright. `\\.\pipe\` is NOT per-session, so an agent living in the
        # desktop session is the bridge, and every session-0 call forwards into it.
        #
        # Measured on a14 20/08/2026: without the agent, `ssh a14 tongue` errors; with
        # it, 6/6 reads return a token and `tongue en`/`tongue vi` change VKey for real.
        #
        # This buys reach, NOT speed: one ssh leg to this box costs 452 ms multiplexed
        # / 829 ms not. Do not wire it into anything latency-sensitive -- tongue.nvim
        # deliberately does not route here, see ime-route's SKIP_HOSTS.
        $userId    = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        $action    = New-ScheduledTaskAction -Execute $exe -Argument 'agent'
        $trigger   = New-ScheduledTaskTrigger -AtLogon
        # LogonType Interactive is the whole point: a task in session 0 would be on the
        # wrong side of the very wall this bridges.
        $principal = New-ScheduledTaskPrincipal -UserId $userId -LogonType Interactive -RunLevel Limited
        # Two flags that fail SILENTLY when missing, both measured on this machine:
        #   -AllowStartIfOnBatteries : without it the task sits at State=Queued forever
        #     with LastTaskResult=0, no error anywhere. This is a laptop.
        #   -MultipleInstances Parallel : the IgnoreNew default drops a start that
        #     overlaps a running instance, silently -- one call never ran for 40 s.
        #     It matters less for a long-lived agent than for an on-demand task, but a
        #     restart racing the old instance is exactly when you need it.
        # ExecutionTimeLimit 0 because the agent is meant to outlive the logon session.
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
            -StartWhenAvailable -MultipleInstances Parallel -ExecutionTimeLimit 0

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
