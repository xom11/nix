#Requires AutoHotkey v2.0
Persistent

; --- Configuration ---
; Define apps for Vietnamese (VI)
GroupAdd "VI_Group", "ahk_exe brave.exe"
GroupAdd "VI_Group", "ahk_exe winword.exe"

; Language IDs (LCID)
EN := 0x0409 ; English (United States)
VN := 0x042A ; Vietnamese

; Fix using EVkey, Evkey active in en (us), so chang en (us) to type vn and en (New Zealand) to type en
; Install Evkey, turn on (Tắt layout trên bàn phím khác US)
; BUG: kanata config with evkey 
; EN := 0x1409 ; English (New Zealand) -> en 
; VN := 0x0409 ; English (United States) -> vn
; ---------------------

SetTimer(AutoSwitchLanguage, 500)
lastHwnd := 0

AutoSwitchLanguage() {
    global lastHwnd
    activeHwnd := WinActive("A")

    ; Only trigger if the active window changes
    if (activeHwnd == 0 || activeHwnd == lastHwnd)
        return

    if WinActive("ahk_group VI_Group") {
        SetInputLang(VN)
    }
    else {
        SetInputLang(EN )
    }

    lastHwnd := activeHwnd
}

SetInputLang(langID) {
    ; WM_INPUTLANGCHANGEREQUEST = 0x0050
    PostMessage(0x0050, 0, langID, , "A")
}
