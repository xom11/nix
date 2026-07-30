Describe 'windows AutoHotkey runtime safety' {
    # Everything here actually launches AutoHotkey, which is why windows-tests.yml skips this
    # one file: the CI runner has no AutoHotkey. Keep it that way -- assertions that only read
    # the .ahk files as text belong in switchLanguage.Tests.ps1, where CI does run them. An
    # assertion parked here once drifted for months precisely because nothing ran it.
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:AhkExe = 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe'
        $script:SwitchLanguagePath = Join-Path $RepoRoot 'home-manager\dotfiles\windows\ahk\switch-language.ahk'
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
        # For the same reason, do not point /validate at a file meant to be #Include'd:
        # tab-key.ahk alone cannot resolve SwitchMode and hangs on the resulting dialog.
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
}
