Describe 'windows AutoHotkey privilege model' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:MainAhk = Get-Content -Raw (Join-Path $RepoRoot 'home-manager\dotfiles\windows\ahk\main.ahk')
        $script:LaunchKanata = Get-Content -Raw (Join-Path $RepoRoot 'home-manager\dotfiles\windows\ahk\launch-kanata.ahk')
        $script:AhkTaskModule = Get-Content -Raw (Join-Path $RepoRoot 'windows\modules\services\ahk\module.ps1')
        $script:AhkWatchdogModule = Get-Content -Raw (Join-Path $RepoRoot 'windows\modules\services\ahk-watchdog\module.ps1')
        $script:ApplyText = Get-Content -Raw (Join-Path $RepoRoot 'windows\apply.ps1')
        $script:KanataTaskModulePath = Join-Path $RepoRoot 'windows\modules\services\kanata\module.ps1'
    }

    It 'does not elevate the whole AutoHotkey process' {
        $script:MainAhk | Should Not Match 'A_IsAdmin'
        $script:MainAhk | Should Not Match '\*RunAs'
        $script:MainAhk | Should Not Match '#Include launch-kanata\.ahk'
    }

    It 'runs the AutoHotkey scheduled task as a limited user process' {
        $script:AhkTaskModule | Should Match 'RunLevel Limited'
        $script:AhkTaskModule | Should Not Match 'RunLevel Highest'
        $script:AhkTaskModule | Should Not Match 'Run as Admin'
    }

    It 'never lets the task itself be what ends the resident script' {
        # main.ahk is Persistent, and the default PT72H the task once carried would have had
        # Task Scheduler kill a healthy script after three days of uptime.
        $script:AhkTaskModule | Should Match '-ExecutionTimeLimit 0'
        $script:AhkTaskModule | Should Match '-Trigger \$triggers'
    }

    It 'arms the watchdog as its own task, live without waiting for a logon' {
        # Two reasons it is not a trigger on AHKrunning: a Repetition hung off the logon trigger
        # only starts counting when that trigger next fires, so it does nothing on an
        # already-logged-on machine; and a timed repeat on the resident task stopped being a
        # no-op once Reload() replaced the process Task Scheduler tracked. Full account in
        # windows\modules\services\ahk-watchdog\module.ps1 and ahkWatchdog.Tests.ps1.
        $script:AhkWatchdogModule | Should Match '\$trigger\s*=\s*New-ScheduledTaskTrigger\s+-Once'
        $script:AhkWatchdogModule | Should Match 'RepetitionInterval'
        $script:AhkTaskModule | Should Not Match '\$logonTrigger\.Repetition\s*='
        # A moving anchor would re-register the task on every apply run.
        $script:AhkWatchdogModule | Should Not Match '-Once\s+-At\s+\(Get-Date\)'
    }

    It 'revives the script at the same privilege level the logon task starts it' {
        # The script inherits the launcher's level, so a Highest watchdog would silently promote
        # main.ahk to an elevated process on every revival.
        $script:AhkWatchdogModule | Should Match 'RunLevel Limited'
        $script:AhkWatchdogModule | Should Not Match 'RunLevel Highest'
    }

    It 'keeps Kanata isolated in its own elevated scheduled task' {
        Test-Path -LiteralPath $script:KanataTaskModulePath | Should Be $true
        $kanataTaskModule = Get-Content -Raw $script:KanataTaskModulePath

        $script:ApplyText | Should Match ([regex]::Escape("'services.kanata'"))
        $kanataTaskModule | Should Match 'kanata'
        $kanataTaskModule | Should Match 'RunLevel Highest'
        $script:LaunchKanata | Should Match 'kanata_windows\.kbd'
    }

    It 'runs Kanata through the hidden AutoHotkey launcher' {
        $kanataTaskModule = Get-Content -Raw $script:KanataTaskModulePath

        $kanataTaskModule | Should Match 'AutoHotkey64'
        $kanataTaskModule | Should Match 'launch-kanata\.ahk'
        $kanataTaskModule | Should Not Match 'kanata_windows_tty_winIOv2_x64\.exe'
        $kanataTaskModule | Should Not Match 'kanata_windows_gui_winIOv2_x64\.exe'
        $kanataTaskModule | Should Match 'WorkingDirectory'
        $kanataTaskModule | Should Not Match 'scoop\\shims\\kanata\.exe'
    }

    It 'orders kanata after VKey by waiting on VKey, not by a trigger delay' {
        # A flat delay here was a guess at how long VKey takes to register its LL hook, and the
        # measured a14 boot put VKey's process start at explorer + 4643 ms -- close enough to
        # the old PT5S that the ordering was very nearly a coin flip. The launcher now waits on
        # VKey itself, so the delay must stay gone: adding one back would only postpone the
        # thing already doing the waiting, and would silently restore five seconds of raw
        # keyboard at every logon.
        $kanataTaskModule = Get-Content -Raw $script:KanataTaskModulePath
        $kanataTaskModule | Should Not Match '\$trigger\.Delay\s*='

        $script:LaunchKanata | Should Match 'WaitForVKey'
        $script:LaunchKanata | Should Match 'WaitForInputIdle'
        $script:LaunchKanata | Should Match 'VKey\.exe'
    }

    It 'waits for VKey before killing the running kanata, not after' {
        # Everything between ProcessClose and the new hook going live is raw-keyboard time.
        # Waiting on the far side of the teardown would add the whole VKey margin to it.
        $body = [regex]::Match($script:LaunchKanata, 'StartKanata\(quiet[\s\S]*').Value
        $body | Should Match 'WaitForVKey\('
        $body | Should Match 'ProcessClose\('
        # Not Should BeGreaterThan: Pester here is 3.4.0, where a bare negative literal after
        # the operator parses as a switch parameter.
        ($body.IndexOf('ProcessClose(') -gt $body.IndexOf('WaitForVKey(')) | Should Be $true
    }

    It 'starts kanata with --nodelay so the startup gap is not 2.8 seconds' {
        # Measured on a14 2026-08-07: spawn -> "Starting kanata proper" is 2837 ms by default
        # and 102 ms with --nodelay. That gap is when the physical CapsLock is a real CapsLock,
        # on every logon and every wake.
        $script:LaunchKanata | Should Match '--nodelay'
    }

    It 'keeps the Kanata launcher hidden and independent of PATH' {
        # The launcher resolves the binary itself rather than going through the scoop shim, so
        # ProcessExist/ProcessClose can target the real process name before restarting it.
        $script:LaunchKanata | Should Match 'scoop\\apps\\kanata\\current\\kanata_windows_tty_winIOv2_x64\.exe'
        $script:LaunchKanata | Should Not Match 'scoop\\shims\\kanata\.exe'
        $script:LaunchKanata | Should Match 'Run\(KanataExe .+ "Hide"\)'
    }
}
