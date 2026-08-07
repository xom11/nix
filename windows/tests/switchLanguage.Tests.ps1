Describe 'windows AutoHotkey script invariants' {
    # These read the .ahk files as text and never launch AutoHotkey, so unlike
    # ahkRuntimeSafety.Tests.ps1 they run in CI. That split is deliberate: the assertion this
    # file's first test replaced had drifted out of sync with switch-language.ahk during the
    # move to tongue and stayed that way, because it lived in the one file CI skips.
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:SwitchLanguage = Get-Content -Raw (Join-Path $RepoRoot 'home-manager\dotfiles\windows\ahk\switch-language.ahk')
        $script:WindowManager = Get-Content -Raw (Join-Path $RepoRoot 'home-manager\dotfiles\windows\ahk\window-manager.ahk')
    }

    It 'switches mode through tongue, at most once per window change' {
        # This replaced an assertion on SetInputLang(VN, activeHwnd) / SetInputLang(EN,
        # activeHwnd). That call site is gone on purpose, and so is the property it guarded: a
        # "mode" is two switches -- the system layout and the VKey engine -- and SetInputLang
        # only ever reached the first. tongue owns both and flips them machine-wide, so there is
        # no hwnd left to pin the switch to.
        $script:SwitchLanguage | Should Match 'Run\(TONGUE'
        $script:SwitchLanguage | Should Not Match 'SwitchMode\(WinActive\("A"\)'
        # Hidden: one tongue.exe console flashing up on every window change would be unusable.
        $script:SwitchLanguage | Should Match '"Hide"'
        # Both guards matter for the same reason. The timer fires every 500ms while one tongue
        # call costs 200-300ms, so dropping either one queues overlapping tongue.exe processes.
        $script:SwitchLanguage | Should Match 'activeHwnd == lastHwnd'
        $script:SwitchLanguage | Should Match 'mode == lastMode'
    }

    It 'forgets the mode when tongue fails rather than claiming it took' {
        # Holding on to lastMode after a failure leaves the script convinced the machine is in a
        # mode it never reached, and the equality guard above then blocks every retry.
        $body = [regex]::Match($script:SwitchLanguage, '(?s)SwitchMode\(mode\)\s*\{.*?\r?\n\}').Value
        $body | Should Match 'catch'
        $body | Should Match 'lastMode := ""'
    }

    It 'keeps tongue as the only path, with no layout-only fallback beside it' {
        # This test used to assert the opposite: that a SetInputLang fallback stayed intact at
        # the bottom of the file, kept in case tongue broke. It was removed on 2026-08-07 and
        # the assertion inverted with it, because the fallback was never the safety net it
        # looked like. A "mode" is two switches -- the system layout and the VKey engine -- and
        # that code could only ever reach the first. Falling back to it would have quietly
        # restored the exact desync tongue was introduced to fix, while reading as a recovery.
        #
        # Matched on call shapes, not bare names: the comments left in switch-language.ahk say
        # why the fallback went, and naming it there must not fail this test.
        $script:SwitchLanguage | Should Not Match 'SetInputLang\('
        $script:SwitchLanguage | Should Not Match 'DllCall\("ActivateKeyboardLayout"'
        $script:SwitchLanguage | Should Not Match 'DllCall\("LoadKeyboardLayout"'
        $script:SwitchLanguage | Should Not Match 'DllCall\("GetKeyboardLayoutList"'
        $script:SwitchLanguage | Should Not Match 'PostMessage\(0x0050'
    }

    It 'keeps window snapping errors from surfacing as AutoHotkey dialogs' {
        $script:WindowManager | Should Match 'try\s*\{[\s\S]*WinRestore'
        $script:WindowManager | Should Match 'catch\s*\{[\s\S]*return'
    }
}
