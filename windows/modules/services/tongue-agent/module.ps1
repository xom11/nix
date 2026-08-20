@{
    Description = 'Scheduled task: tongue agent — bridges session 0 (SSH) to the desktop session'
    Apply       = {
        param($Ctx)
        $taskName = 'TongueAgent'

        # `.local\bin` deliberately, not a scoop shim: tongue on Windows is installed by
        # hand (see CLAUDE.md, "Windows — tongue"), and that directory precedes scoop on
        # PATH here anyway.
        $exe = Join-Path $env:USERPROFILE '.local\bin\tongue.exe'
        if (-not (Test-Path $exe)) {
            Write-Warn "tongue.exe not found at $exe"
            return
        }
        # Version gate, same shape as the dotpkg 0.2.0 one and for the same reason: the
        # install channel here is a manual copy, so "old binary, new module" is the
        # DEFAULT state rather than an exception. An older tongue takes `agent` as an
        # unknown subcommand and exits 2 at once -- the task would then sit at
        # State=Ready looking perfectly healthy.
        if (-not (& $exe --help 2>&1 | Select-String -SimpleMatch 'agent' -Quiet)) {
            Write-Warn 'tongue.exe has no `agent` subcommand -- copy a newer build to .local\bin'
            return
        }
        # Same gate one level down, and it is NOT redundant: a build that has `agent` but
        # not `--listen` takes the flag as an unexpected argument and exits at once, so
        # the task would sit at State=Ready looking healthy while the tunnel finds nobody
        # listening. Checking `agent --help` rather than `--help`: the flag lives on the
        # subcommand, and the top-level help never mentions it.
        if (-not (& $exe agent --help 2>&1 | Select-String -SimpleMatch 'listen' -Quiet)) {
            Write-Warn 'tongue.exe `agent` has no --listen -- copy a newer build to .local\bin'
            return
        }

        # Why this task exists: Windows OpenSSH is a service, so the shell it spawns lands
        # in SESSION 0. Both mechanisms tongue drives VKey with are per-session -- window
        # station (FindWindow) and the `Local\` namespace (OpenFileMapping) -- so
        # `ssh a14 tongue vi` cannot reach the user's VKey. `\\.\pipe\` is NOT per-session,
        # so an agent in the desktop session bridges it and session-0 calls forward in.
        #
        # ONE task, NO watchdog, and that is a decision. beckon/kanata/main.ahk must be
        # resident because they serve every keypress; tongue-over-ssh is request/response,
        # a few times a day, driven by a human. The healthy path IS the normal path: the
        # client runs `schtasks /run` itself when it finds no pipe, and the agent exits
        # after ten idle minutes. Copying beckon's five-minute watchdog here would be a
        # permanent polling loop for something almost nobody calls.
        #
        # `conhost --headless`: a `-LogonType Interactive` task running a console exe gets
        # a console from Windows BEFORE main() runs, and with Windows Terminal as default
        # that console arrives as a NEW TAB indistinguishable from one you opened. Closing
        # it kills the agent. Measured and written up at services/beckon-serve; the same
        # trap applies verbatim here. Point at the real exe, not a shim.
        # Second door, for the reverse tunnel. The pipe above serves session-0 calls, and
        # every one of those pays for a fresh PowerShell before doing any work -- 293 ms
        # of the 656 ms a leg costs, measured on this machine 2026-08-20. That is the whole
        # budget for something that runs on every exit from Insert mode.
        #
        # A call arriving through `ssh -R` pays none of it: no shell is spawned, and this
        # end of the pipe is already in the desktop session where VKey lives. Measured
        # 11.6 ms round trip against 656 ms.
        #
        # THE PORT IS WRITTEN IN THREE PLACES AND NOTHING CROSS-CHECKS THEM:
        #   here, home-manager/programs/ssh/config (RemoteForward), and bin/ime-route
        #   (tunnel_port). A mismatch does not break loudly -- ime-route simply finds
        #   nobody listening and falls back to ssh, i.e. it gets SLOW rather than WRONG.
        #   That is the deliberate shape: the `name` check in the reply makes a mismatch
        #   cost latency, never a switch on the wrong machine.
        #
        # Loopback only. tongue refuses a non-loopback --listen outright, so this is
        # belt and braces rather than the only guard.
        $listen    = '127.0.0.1:47701'
        $userId    = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        $action    = New-ScheduledTaskAction -Execute 'conhost.exe' -Argument "--headless `"$exe`" agent --listen $listen"
        # Exactly ONE trigger: Test-ScheduledTaskMatch checks Triggers.Count -ne 1, so a
        # trigger-less task would be silently re-registered on every apply run. A logon
        # trigger is harmless anyway -- the agent starts, then idles out.
        $trigger   = New-ScheduledTaskTrigger -AtLogon
        # RunLevel Limited, NOT Highest: an elevated agent creates the pipe with a High
        # integrity label, and a Medium-IL client in session 0 then loses write access to
        # a pipe its own user owns. Same reason VKey is pinned Limited.
        $principal = New-ScheduledTaskPrincipal -UserId $userId -LogonType Interactive -RunLevel Limited
        # Three flags, all of which fail SILENTLY when missing, all measured here:
        #   -AllowStartIfOnBatteries : without it the task sits at State=Queued forever
        #     with LastTaskResult=0 and no error anywhere. This is a laptop.
        #   -MultipleInstances Parallel : the IgnoreNew default drops a start that overlaps
        #     a running instance -- one call never ran for 40 s. With lazy start the client
        #     issues `schtasks /run` while an exiting agent may still be alive, which is
        #     exactly the overlap this covers.
        #   -ExecutionTimeLimit 0 : the PT72H default would kill a healthy agent.
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

        # Upgrading tongue.exe: the agent HOLDS the file open, and Windows will not let you
        # overwrite a running .exe. Disable the task, stop the process, copy, re-enable.
    }
}
