#Requires AutoHotkey v2.0
Persistent

; --- Configuration ---
; Define apps for Vietnamese (VI)
GroupAdd "VI_Group", "ahk_exe brave.exe"
GroupAdd "VI_Group", "ahk_exe winword.exe"

; Language IDs (LCID)
EN_US := 0x0409 ; English (United States)
VI_VN := 0x042A ; Vietnamese
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
        SetInputLang(VI_VN)
    }
    else {
        SetInputLang(EN_US)
    }

    lastHwnd := activeHwnd
}

SetInputLang(langID) {
    ; WM_INPUTLANGCHANGEREQUEST = 0x0050
    PostMessage(0x0050, 0, langID, , "A")
}