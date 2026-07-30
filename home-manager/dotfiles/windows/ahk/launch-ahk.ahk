#Requires AutoHotkey v2.0
#SingleInstance Off

; Watchdog launcher for main.ahk, run by the AHKWatchdog task every five minutes.
;
;   (no argument)  Start main.ahk unconditionally. #SingleInstance Force over there means the
;                  new copy replaces whatever was running.
;
;   --if-missing   Start it only when it is gone. This is what the watchdog task uses.
;
; Why the watchdog needs a launcher at all: the repetition used to sit on the AHKrunning task
; itself, leaning on MultipleInstances=IgnoreNew to make every repeat a no-op while the script
; was alive. That only holds while Task Scheduler still owns the process. Reload() -- Tab+r in
; tab-key.ahk -- makes the running copy exit 0 and spawn a replacement Task Scheduler knows
; nothing about, so it logged the instance as completed and the very next repeat launched a
; second main.ahk, whose #SingleInstance Force then killed the freshly reloaded one. Every
; script's state was reset and the startup toast popped out of nowhere, minutes after a reload.
; Asking the desktop whether main.ahk is alive does not care who started it.
;
; #SingleInstance Off because the logon task may be starting main.ahk in the same second this
; runs: the v2 default would have one invocation of this launcher kill the other mid-check.

MainScript := A_ScriptDir . "\main.ahk"

; A script's main window is hidden and titled after its full path. That, rather than
; ProcessExist, is the liveness test: AutoHotkey64.exe is also launch-kanata.ahk, this
; launcher, and anything the owner runs by hand, so a process-name check would report main.ahk
; alive when it is not.
;
; The title is the path *plus a suffix* -- measured on a14, AutoHotkey v2.0.26:
;
;   C:\Users\kln\.nix\home-manager\dotfiles\windows\ahk\main.ahk - AutoHotkey v2.0.26
;
; so this depends on the default TitleMatchMode 2 (contains). Do not "tighten" it to exact
; matching, mode 3: it would never match, every tick would conclude the script is gone, and the
; watchdog would start a duplicate main.ahk every five minutes -- a worse version of the bug it
; exists to fix. ahkWatchdog.Tests.ps1 guards this.
DetectHiddenWindows true

IfMissingOnly := (A_Args.Length >= 1 && A_Args[1] = "--if-missing")

if (IfMissingOnly) {
    if MainAhkAlive()
        ExitApp(0)
    ; The logon task carries a PT15S delay and may be mid-launch right now. Look again before
    ; concluding the script is really gone, otherwise both would start a copy.
    Sleep(1500)
    if MainAhkAlive()
        ExitApp(0)
}

; A_AhkPath, not a hardcoded install path: whichever interpreter is running this launcher is
; the one the task resolved, so the revived script matches the one the logon task starts.
Run('"' . A_AhkPath . '" "' . MainScript . '"')
ExitApp(0)

MainAhkAlive() {
    global MainScript
    return WinExist(MainScript . " ahk_class AutoHotkey") != 0
}
