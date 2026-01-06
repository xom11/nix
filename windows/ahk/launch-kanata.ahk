#Requires AutoHotkey v2.0

userDir := EnvGet("USERPROFILE")

global KanataExe := userDir . "\scoop\shims\kanata.exe"
global KanataConfig := userDir . "\nix\configs\kanata\kanata_windows.kbd"

StartKanata()
StartKanata(*) {
    if ProcessExist("kanata.exe") {
        ProcessClose("kanata.exe")
        ProcessWaitClose("kanata.exe", 2)
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
