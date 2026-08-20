#Requires AutoHotkey v2.0
Persistent
SetTitleMatchMode 2 ; Relative match (contains)

; --- Configuration ---
; Apps that always type Vietnamese
; GroupAdd "VI_Group", "Gemini"
GroupAdd "VI_Group", "Messenger"
GroupAdd "VI_Group", "Telegram"
GroupAdd "VI_Group", "Zalo"
GroupAdd "VI_Group", "Claude"
GroupAdd "VI_Group", "ahk_exe winword.exe"

; Switching is delegated to `tongue` rather than a DllCall, because a "mode" is
; TWO levers -- the system layout and the VKey IME -- and SetInputLang only reaches
; the first. The old version set a Vietnamese Telex layout and relied on VKey not
; touching it, which worked by luck. tongue moves both and reads the machine back
; before reporting success.
;
; The mode -> (layout, IME) map lives in tongue's config.toml, not here.
TONGUE := EnvGet("USERPROFILE") . "\.local\bin\tongue.exe"

SetTimer(AutoSwitchLanguage, 500)
lastHwnd := 0
lastMode := ""

; lastMode avoids spawning redundant processes: the watcher runs every 500 ms while
; each tongue call costs 200-300 ms (it polls the real state back to verify), so
; without it rapid window switching would stack up processes.
;
; On failure the cache is CLEARED rather than kept, so the next attempt retries
; instead of sticking on a mode the machine is not actually in.
SwitchMode(mode) {
    global TONGUE, lastMode
    if (mode == lastMode)
        return
    lastMode := mode
    try {
        Run(TONGUE . " " . mode, , "Hide")
    } catch {
        lastMode := ""
        TrayTip "Khong chay duoc tongue " mode, "tongue", 3
    }
}

AutoSwitchLanguage() {
    global lastHwnd
    activeHwnd := WinActive("A")

    ; only when the active window changed
    if (activeHwnd == 0 || activeHwnd == lastHwnd)
        return
    lastHwnd := activeHwnd

    SwitchMode(WinActive("ahk_group VI_Group") ? "vi" : "en")
}

; A SetInputLang fallback used to live here, calling ActivateKeyboardLayout
; directly. Removed: it moved only ONE of the two levers, so "still works if tongue
; breaks" really meant "reverts to the bug tongue exists to fix". Recover from git
; if ever needed.
