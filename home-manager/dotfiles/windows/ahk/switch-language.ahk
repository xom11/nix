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

; Duoi day tung co SetInputLang -- duong lui goi thang GetKeyboardLayoutList /
; ActivateKeyboardLayout, giu lai phong khi tongue hong. Da xoa 08/2026: no chi
; gat duoc MOT trong hai can (layout he thong), khong dong toi VKey, nen "chay lai
; duoc ngay" that ra la quay ve dung cai bug ma tongue sinh ra de sua. Can xem lai
; thi lay tu git.
