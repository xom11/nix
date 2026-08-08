Describe 'windows AutoHotkey runtime safety' {
    # Everything here actually launches AutoHotkey via the hardcoded path below. That is why
    # windows-tests.yml skips this one file: the runner does now have AutoHotkey (installed for
    # the shortcuts-parser tests), but at $env:RUNNER_TEMP\ahk\AutoHotkey64.exe, not at
    # 'C:\Program Files\AutoHotkey\v2\...' -- this file does not read $env:AHK_EXE, so it still
    # finds nothing there. Keep it excluded until it's parameterized; assertions that only read
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

    It 'does not crash when tongue cannot be run' {
        # Until 2026-08-07 this drove SetInputLang(0x0409, "ahk_id 0") -- a layout-only fallback
        # that has since been deleted, so the call would now be a load-time error. SwitchMode is
        # the only switching path left, which makes "tongue is missing or broken" the only
        # failure this script still has to survive: land in the catch, clear lastMode so the next
        # attempt retries, and carry on.
        #
        # TONGUE is reassigned after the include rather than left at its real value. Pointing it
        # at the installed tongue.exe would exercise the success path instead of the failure one,
        # and would flip the live machine's input mode as a side effect of running the suite.
        $testScript = Join-Path $TestDrive 'switch-language-missing-tongue.ahk'
        @"
#Requires AutoHotkey v2.0
#SingleInstance Force
#Include $script:SwitchLanguagePath
TONGUE := A_ScriptDir . "\no-such-tongue.exe"
SwitchMode("en")
ExitApp(0)
"@ | Set-Content -LiteralPath $testScript -Encoding UTF8

        # Bounded, for the same reason as the test above, and this one learned it the hard way:
        # as an unbounded `& $AhkExe ...` it hung for over ten minutes when the SetInputLang call
        # above stopped resolving, leaving a stray AutoHotkey process holding an invisible error
        # dialog in session 0. A load-time error must fail this test, not stall it.
        #
        # ProcessStartInfo rather than Start-Process: `Start-Process -PassThru` combined with
        # output redirection hands back an object whose ExitCode reads as $null, which made this
        # assertion compare against nothing at all. The test above gets away with Start-Process
        # only because it redirects neither stream.
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName               = $script:AhkExe
        $psi.Arguments              = "/ErrorStdOut `"$testScript`""
        $psi.UseShellExecute        = $false
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError  = $true
        $psi.CreateNoWindow         = $true

        $proc = [System.Diagnostics.Process]::Start($psi)
        # Drain both pipes before waiting, not after: a child that fills one would block on the
        # write while this blocks on the exit.
        $stdout = $proc.StandardOutput.ReadToEndAsync()
        $stderr = $proc.StandardError.ReadToEndAsync()
        if (-not $proc.WaitForExit(20000)) {
            $proc.Kill()
            throw 'AutoHotkey never finished -- most likely a load-time error dialog'
        }

        # Both streams: /ErrorStdOut has sent load-time errors to stdout in some builds.
        $output = $stdout.Result + $stderr.Result

        $proc.ExitCode | Should Be 0
        $output | Should Not Match '==>'
        $output | Should Not Match 'Too many parameters'
    }
}
