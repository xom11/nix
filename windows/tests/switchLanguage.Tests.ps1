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

    It 'keeps the SetInputLang fallback able to switch layout without tongue or VKey' {
        # Nobody calls this any more; it is kept so that a broken or missing tongue can be
        # worked around by pointing AutoSwitchLanguage and tab-key.ahk back at it. That is only
        # true while it still resolves a layout and targets the hwnd it was handed.
        $script:SwitchLanguage | Should Match 'LoadKeyboardLayout'
        $script:SwitchLanguage | Should Match 'ActivateKeyboardLayout'
        $script:SwitchLanguage | Should Match 'Format\("\{:08X\}", langID\)'
        $script:SwitchLanguage | Should Match 'PostMessage\(0x0050, 0, hkl, , "ahk_id " hwnd\)'
    }

    It 'keeps window snapping errors from surfacing as AutoHotkey dialogs' {
        $script:WindowManager | Should Match 'try\s*\{[\s\S]*WinRestore'
        $script:WindowManager | Should Match 'catch\s*\{[\s\S]*return'
    }
}
