Describe 'windows kanata/VKey hook order (evkey-monitor.ahk)' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $AhkDir   = Join-Path $RepoRoot 'home-manager\dotfiles\windows\ahk'
        $Monitor  = Get-Content -Raw -LiteralPath (Join-Path $AhkDir 'evkey-monitor.ahk')
        $Main     = Get-Content -Raw -LiteralPath (Join-Path $AhkDir 'main.ahk')
    }

    It 'is actually loaded by main.ahk' {
        # A monitor that is not #Included is silent and useless.
        $Main | Should Match ([regex]::Escape('#Include evkey-monitor.ahk'))
    }

    It 'covers all three moments VKey may re-register its LL hook' {
        # User-mode has no API to enumerate the WH_KEYBOARD_LL chain, so these three
        # moments are all we can detect. Missing one means a silent order flip.
        # 1. the VKey process just started
        $Monitor | Should Match ([regex]::Escape('ProcessExist("VKey.exe")'))
        # 2. mo khoa may
        $Monitor | Should Match '0x02B1'
        $Monitor | Should Match 'WTS_SESSION_UNLOCK\s*:=\s*0x8'
        # 3. thuc tu sleep
        $Monitor | Should Match '0x0218'
        $Monitor | Should Match 'PBT_APMRESUMEAUTOMATIC\s*:=\s*0x12'
    }

    It 'registers for session notifications, otherwise unlock never arrives' {
        # Without WTSRegisterSessionNotification, WM_WTSSESSION_CHANGE never reaches the
        # script's window and the unlock branch becomes dead code.
        $Monitor | Should Match 'WTSRegisterSessionNotification'
        $Monitor | Should Match 'A_ScriptHwnd'
    }

    It 'debounces so wake+unlock do not restart kanata twice' {
        # Wake and unlock almost always fire together, and each kanata restart drops keys.
        $Monitor | Should Match '__vk_debounce'
        $Monitor | Should Match 'A_TickCount\s*-\s*__vk_lastRequest'
    }

    It 'delays on unlock/resume but not when VKey just appeared' {
        # Process branch: VKey is KNOWN to have just started, so restart immediately.
        $Monitor | Should Match ([regex]::Escape('RequestKanataRestart()'))
        # Unlock/resume branch: VKey may re-register a beat after us, and restarting too
        # early just lets it back on top.
        $Monitor | Should Match ([regex]::Escape('RequestKanataRestart(__vk_settleDelay)'))
        $Monitor | Should Match '__vk_settleDelay\s*:=\s*\d+'
    }

    It 'goes through the elevated Kanata task, not a direct kanata launch' {
        # The "Kanata" task force-restarts it, and only Task Scheduler can grant the admin
        # context needed to reinstall the hook.
        $Monitor | Should Match ([regex]::Escape('schtasks /run /tn "Kanata"'))
        $Monitor | Should Not Match 'kanata_windows_'
    }

    It 'records why wintercept is not an option on this hardware' {
        # This machine is ARM64, and a wintercept build needs Interception's x64 kernel
        # driver, which Windows on ARM cannot load. Recorded so nobody proposes it again.
        $Monitor | Should Match 'ARM64'
        $Monitor | Should Match 'wintercept'
    }
}
