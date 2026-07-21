#Requires AutoHotkey v2.0

userDir := EnvGet("USERPROFILE")

global KanataExe := userDir . "\scoop\apps\kanata\current\kanata_windows_tty_winIOv2_x64.exe"
global KanataConfig := userDir . "\.nix\configs\kanata\kanata_windows.kbd"

SplitPath(KanataExe, &KanataProc)  ; process name = exe filename, e.g. kanata_..._cmd_allowed_x64.exe

StartKanata()
StartKanata(*) {
    global KanataProc
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
        MsgBox "Error: Kanta config not found!`n`nExe: " . KanataExe . "`nConfig: " . KanataConfig
    }
}
