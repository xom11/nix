Describe 'windows AutoHotkey runtime safety' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:AhkExe = 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe'
        $script:SwitchLanguagePath = Join-Path $RepoRoot 'home-manager\dotfiles\windows\ahk\switch-language.ahk'
        $script:WindowManagerPath = Join-Path $RepoRoot 'home-manager\dotfiles\windows\ahk\window-manager.ahk'
        $script:SwitchLanguage = Get-Content -Raw $script:SwitchLanguagePath
        $script:WindowManager = Get-Content -Raw $script:WindowManagerPath
        $script:LaunchAhkPath = Join-Path $RepoRoot 'home-manager\dotfiles\windows\ahk\launch-ahk.ahk'
    }

    It 'parses the watchdog launcher as valid AutoHotkey v2' {
        # Every other check on launch-ahk.ahk only greps the text; nothing parses it, and a
        # syntax error there means the watchdog silently stops reviving main.ahk. The launcher
        # is standalone (no #Include), so /validate is a real gate for it.
        #
        # Bounded wait, not a plain call: a load-time error surfaces as a modal dialog, and one
        # raised in a session with no visible desktop -- an SSH run, for instance -- blocks
        # forever. That is exactly how a stray AutoHotkey process was once left behind here.
        $proc = Start-Process -FilePath $script:AhkExe -PassThru -WindowStyle Hidden `
            -ArgumentList '/validate', "`"$script:LaunchAhkPath`""
        if (-not $proc.WaitForExit(20000)) {
            $proc.Kill()
            throw 'AutoHotkey /validate never finished -- most likely a load-time error dialog'
        }
        $proc.ExitCode | Should Be 0
    }

    It 'does not crash when switching language for a missing target window' {
        $testScript = Join-Path $TestDrive 'switch-language-missing-target.ahk'
        @"
#Requires AutoHotkey v2.0
#SingleInstance Force
#Include $script:SwitchLanguagePath
SetInputLang(0x0409, "ahk_id 0")
ExitApp(0)
"@ | Set-Content -LiteralPath $testScript -Encoding UTF8

        $output = & $script:AhkExe /ErrorStdOut $testScript 2>&1 | Out-String

        $LASTEXITCODE | Should Be 0
        $output | Should Not Match '==>'
        $output | Should Not Match 'Too many parameters'
    }

    It 'pins language switching to the hwnd observed by the timer' {
        $script:SwitchLanguage | Should Match 'SetInputLang\(VN, activeHwnd\)'
        $script:SwitchLanguage | Should Match 'SetInputLang\(EN, activeHwnd\)'
        $script:SwitchLanguage | Should Match 'PostMessage\(0x0050, 0, hkl, , "ahk_id " hwnd\)'
    }

    It 'loads and activates keyboard layouts before requesting the target window switch' {
        $script:SwitchLanguage | Should Match 'LoadKeyboardLayout'
        $script:SwitchLanguage | Should Match 'ActivateKeyboardLayout'
        $script:SwitchLanguage | Should Match 'Format\("\{:08X\}", langID\)'
    }

    It 'keeps window snapping errors from surfacing as AutoHotkey dialogs' {
        $script:WindowManager | Should Match 'try\s*\{[\s\S]*WinRestore'
        $script:WindowManager | Should Match 'catch\s*\{[\s\S]*return'
    }
}
