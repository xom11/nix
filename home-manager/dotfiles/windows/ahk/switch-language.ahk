#Requires AutoHotkey v2.0
Persistent
SetTitleMatchMode 2 ; Relative match (contains)

; --- Cau hinh ---
; Cac app luon go tieng Viet
; GroupAdd "VI_Group", "Gemini"
GroupAdd "VI_Group", "Messenger"
GroupAdd "VI_Group", "Telegram"
GroupAdd "VI_Group", "Zalo"
GroupAdd "VI_Group", "Claude"
GroupAdd "VI_Group", "ahk_exe winword.exe"

; Viec doi che do go giao han cho `tongue` (github:xom11/tongue), khong tu goi
; DllCall nua. Ly do: mot "che do" that ra la HAI can gat -- layout he thong va
; bo go VKey -- ma SetInputLang chi voi toi cai thu nhat. Ban cu dat VN =
; 0x0409042A (layout Vietnamese Telex) roi trong cay vao viec VKey khong dung
; toi layout do; dung duoc la nho may. tongue gat ca hai roi doc lai may de
; chac chan da doi that moi bao thanh cong.
;
; Doi ban do che do -> (layout, bo go) thi sua %APPDATA%\tongue\config.toml,
; khong sua file nay.
TONGUE := EnvGet("USERPROFILE") . "\.local\bin\tongue.exe"

SetTimer(AutoSwitchLanguage, 500)
lastHwnd := 0
lastMode := ""

; Doi che do go qua tongue.
;
; Nho lastMode de khong spawn tien trinh thua: AutoSwitchLanguage chay moi 500ms,
; ma moi lan goi tongue ton ~200-300ms (no con poll doc lai trang thai that de
; verify roi moi thoat). Khong nho thi doi cua so lien tuc se xep hang mot dong
; tongue.exe chong nhau.
;
; That bai thi xoa lastMode chu khong giu: lan sau con thu lai, thay vi ket o
; mot che do ma may khong he o do.
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

    ; Chi chay khi cua so active doi
    if (activeHwnd == 0 || activeHwnd == lastHwnd)
        return
    lastHwnd := activeHwnd

    SwitchMode(WinActive("ahk_group VI_Group") ? "vi" : "en")
}

; ---------------------------------------------------------------------------
; Duoi day la duong lui, KHONG con ai goi sau khi chuyen sang tongue.
;
; Giu lai vi no doi duoc layout ma khong can toi VKey: neu tongue hong hoac
; chua cai, tro AutoSwitchLanguage va tab-key.ahk ve SetInputLang la chay lai
; duoc ngay. Xoa han thi luc can se phai viet lai tu dau.
; ---------------------------------------------------------------------------

EN := 0x0409       ; English (United States)
VN := 0x0409042A   ; Vietnamese Telex (US Keyboard Layout + Vietnamese Language)

SetInputLang(langID, hwnd := 0) {
    if !hwnd
        hwnd := WinActive("A")
    if !hwnd
        return false

    hkl := 0
    size := DllCall("GetKeyboardLayoutList", "Int", 0, "Ptr", 0)
    buf := Buffer(size * A_PtrSize)
    DllCall("GetKeyboardLayoutList", "Int", size, "Ptr", buf)

    ; 1. Try exact match (e.g. 0x0409042A)
    Loop size {
        item := NumGet(buf, (A_Index - 1) * A_PtrSize, "Ptr")
        if (item == langID) {
            hkl := item
            break
        }
    }
    ; 2. Try low-word match (e.g. 0x0409 matching 0x04090409)
    if !hkl {
        Loop size {
            item := NumGet(buf, (A_Index - 1) * A_PtrSize, "Ptr")
            if ((item & 0xFFFF) == (langID & 0xFFFF)) {
                hkl := item
                break
            }
        }
    }
    ; 3. Fallback: try to load it via LoadKeyboardLayout
    if !hkl {
        layoutID := Type(langID) = "String" ? langID : Format("{:08X}", langID)
        hkl := DllCall("LoadKeyboardLayout", "Str", layoutID, "UInt", 1, "Ptr")
    }

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
