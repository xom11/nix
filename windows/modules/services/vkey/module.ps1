@{
    Description = 'Scheduled task: keep VKey unelevated and undelayed at logon'
    Apply = {
        param($Ctx)
        $taskName = 'VKey'

        # This module does NOT create the task. VKey creates it itself -- its config.toml carries
        # `run_at_startup = true` -- so the repo owning its existence would mean two writers for
        # one object. What the repo owns is two properties of it, both of which have already been
        # fixed by hand once and would be lost the moment VKey rewrote the task:
        #
        #   RunLevel = Limited    An elevated VKey puts UIPI between it and `tongue`, so
        #                         PostMessage from a Medium-integrity process is dropped and
        #                         language switching silently stops working. This was found the
        #                         hard way on 2026-07-30: the task shipped as RunLevel=Highest.
        #
        #   no trigger delay      The task carried a flat PT5S. That delay was the entire reason
        #                         VKey did not start until explorer + 4643 ms, which in turn set
        #                         the floor on how early kanata could take over the keyboard --
        #                         kanata must register its WH_KEYBOARD_LL hook after VKey's, so
        #                         launch-kanata.ahk blocks until VKey is ready. A late VKey is a
        #                         late kanata, and every millisecond there is a millisecond where
        #                         the physical CapsLock is a real CapsLock.
        #
        # Removing the delay is safe precisely because launch-kanata.ahk waits on VKey rather than
        # on a clock: VKey starting earlier just unblocks the launcher sooner, it cannot invert
        # the hook order. Do not remove the delay here without that wait in place.

        $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        if (-not $task) {
            # Not an error: on a machine where VKey has not run yet the task does not exist, and
            # VKey will create it on first launch. The next apply run picks it up.
            Write-Warn "scheduled task '$taskName' not found (VKey creates it on first run)"
            return
        }

        $wrongLevel = $task.Principal.RunLevel -ne 'Limited'
        $delays     = @($task.Triggers | ForEach-Object { [string]$_.Delay } | Where-Object { $_ })
        $wrongDelay = $delays.Count -gt 0

        if (-not $wrongLevel -and -not $wrongDelay) {
            Write-Skip "scheduled task: $taskName (Limited, no delay)"
            return
        }

        $changed = @()

        if ($wrongDelay) {
            foreach ($tr in $task.Triggers) { $tr.Delay = '' }
            Set-ScheduledTask -TaskName $taskName -Trigger $task.Triggers | Out-Null
            $changed += "delay $($delays -join ',') -> none"
        }

        if ($wrongLevel) {
            $principal = New-ScheduledTaskPrincipal -UserId $task.Principal.UserId `
                -LogonType Interactive -RunLevel Limited
            Set-ScheduledTask -TaskName $taskName -Principal $principal | Out-Null
            $changed += "RunLevel $($task.Principal.RunLevel) -> Limited"
        }

        Write-OK "scheduled task: $taskName ($($changed -join '; '))"
    }
}
