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

    It 'runs Kanata through the hidden AutoHotkey launcher after the logon session settles' {
        $kanataTaskModule = Get-Content -Raw $script:KanataTaskModulePath

        $kanataTaskModule | Should Match 'AutoHotkey64'
        $kanataTaskModule | Should Match 'launch-kanata\.ahk'
        $kanataTaskModule | Should Not Match 'kanata_windows_tty_winIOv2_x64\.exe'
        $kanataTaskModule | Should Not Match 'kanata_windows_gui_winIOv2_x64\.exe'
        $kanataTaskModule | Should Match '\$trigger\.Delay\s*=\s*''PT5S'''
        $kanataTaskModule | Should Match 'WorkingDirectory'
        $kanataTaskModule | Should Not Match 'scoop\\shims\\kanata\.exe'
    }

    It 'keeps the Kanata launcher hidden and independent of PATH' {
        # The launcher resolves the binary itself rather than going through the scoop shim, so
        # ProcessExist/ProcessClose can target the real process name before restarting it.
        $script:LaunchKanata | Should Match 'scoop\\apps\\kanata\\current\\kanata_windows_tty_winIOv2_x64\.exe'
        $script:LaunchKanata | Should Not Match 'scoop\\shims\\kanata\.exe'
        $script:LaunchKanata | Should Match 'Run\(KanataExe .+ "Hide"\)'
    }
}
