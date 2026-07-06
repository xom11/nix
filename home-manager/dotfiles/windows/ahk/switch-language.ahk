#Requires AutoHotkey v2.0
Persistent
SetTitleMatchMode 2 ; Relative match (contains)

; --- Configuration ---
; Define apps for Vietnamese (VI) - using winTitle for more granular control
; GroupAdd "VI_Group", "Gemini"
GroupAdd "VI_Group", "Messenger"
GroupAdd "VI_Group", "Telegram"
GroupAdd "VI_Group", "Zalo"
GroupAdd "VI_Group", "Claude"
GroupAdd "VI_Group", "ahk_exe winword.exe"

; Language IDs (LCID)
EN := 0x0409 ; English (United States)
VN := "0001042A" ; Vietnamese

; Fix using EVkey, Evkey active in en (us), so chang en (us) to type vn and en (New Zealand) to type en
; Install Evkey, turn on (Tắt layout trên bàn phím khác US)
; BUG: kanata config with evkey 
; EN := 0x1409 ; English (New Zealand) -> en 
; VN := 0x0409 ; English (United States) -> vn
; ---------------------

SetTimer(AutoSwitchLanguage, 500)
lastHwnd := 0

AutoSwitchLanguage() {
    global lastHwnd, EN, VN
    activeHwnd := WinActive("A")

    ; Only trigger if the active window changes
    if (activeHwnd == 0 || activeHwnd == lastHwnd)
        return

    if WinActive("ahk_group VI_Group") {
        SetInputLang(VN, activeHwnd)
    }
    else {
        SetInputLang(EN, activeHwnd)
    }

    lastHwnd := activeHwnd
}

SetInputLang(langID, hwnd := 0) {
    if !hwnd
        hwnd := WinActive("A")
    if !hwnd
        return false

    layoutID := Type(langID) = "String" ? langID : Format("{:08X}", langID)
    hkl := DllCall("LoadKeyboardLayout", "Str", layoutID, "UInt", 1, "Ptr")
    if !hkl
        return false
    DllCall("ActivateKeyboardLayout", "Ptr", hkl, "UInt", 0, "Ptr")

    ; WM_INPUTLANGCHANGEREQUEST = 0x0050
    try {
        PostMessage(0x0050, 0, hkl, , "ahk_id " hwnd)
        return true
    } catch {
        return false
    }
}
