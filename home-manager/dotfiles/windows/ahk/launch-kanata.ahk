#Requires AutoHotkey v2.0
#SingleInstance Off

; Two modes, chosen by whoever launches this:
;
;   (no argument)  Force restart. Used by the Kanata task at logon and by evkey-monitor.ahk
;                  after VKey restarts -- there the entire point is to tear kanata down and
;                  bring it back so its WH_KEYBOARD_LL hook re-registers in the right order.
;
;   --if-missing   Start kanata only when it is gone. The KanataWatchdog task runs this on a
;                  timer, and killing a healthy kanata every few minutes would drop keystrokes.
;
; #SingleInstance Off because both tasks run this same file: the v2 default would have one
; invocation kill the other mid-launch.

userDir := EnvGet("USERPROFILE")

global KanataExe := userDir . "\scoop\apps\kanata\current\kanata_windows_tty_winIOv2_x64.exe"
global KanataConfig := userDir . "\.nix\configs\kanata\kanata_windows.kbd"

SplitPath(KanataExe, &KanataProc)  ; process name = exe filename, e.g. kanata_..._cmd_allowed_x64.exe

IfMissingOnly := (A_Args.Length >= 1 && A_Args[1] = "--if-missing")

if (IfMissingOnly) {
    if ProcessExist(KanataProc)
        ExitApp(0)
    ; The logon task may be starting kanata this very second. Look again before concluding it
    ; is really gone, otherwise both would launch a copy and the two would fight over the
    ; keyboard hook.
    Sleep(1500)
    if ProcessExist(KanataProc)
        ExitApp(0)
}

StartKanata(IfMissingOnly)
ExitApp(0)

StartKanata(quiet := false) {
    global KanataProc, KanataExe, KanataConfig

    if ProcessExist(KanataProc) {
        ProcessClose(KanataProc)
        ProcessWaitClose(KanataProc, 2)
    }

    if GetKeyState("CapsLock", "T") {
        SetCapsLockState "AlwaysOff"
        SetCapsLockState "Off"
    }

    try {
        Run(KanataExe ' -c "' . KanataConfig . '"', , "Hide")
    } catch {
        ; The watchdog runs unattended every few minutes; a MsgBox there would stack up a new
        ; dialog on the desktop each time.
        if (!quiet)
            MsgBox "Error: Kanata config not found!`n`nExe: " . KanataExe . "`nConfig: " . KanataConfig
    }
}
