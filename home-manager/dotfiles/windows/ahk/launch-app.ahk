#Requires AutoHotkey v2.0

; Bang phim song o configs/shortcuts/apps.toml, dung chung voi macOS, GNOME va
; sway. File nay chi con viec bind phim va goi beckon.
;
; Lop 1 = Cap + <key>          (^#!)
; Lop 2 = Cap + Shift + <key>  (^#!+)
;
; Truoc day lop 2 la chord Cap+a roi phim, qua lib/which-key.ahk. Chuyen sang
; modifier don giup GNOME co lop 2 lan dau (dconf khong lam duoc chord) va xoa
; ba ban trien khai chord rieng cua ba nen tang.

#Include %A_ScriptDir%\..\..\..\..\configs\shortcuts\parse.ahk

LaunchAppFail(msg) {
    TrayTip(msg, "LaunchApp", 3)
    ; LogLine() dinh nghia trong main.ahk, ghi vao %LOCALAPPDATA%\ahk-main.log.
    ; try de file nay chay doc lap duoc khi go loi.
    try LogLine("launch-app  " msg)
}

Beckon(name) {
    try {
        code := RunWait('beckon.exe "' name '"', , "Hide")
    } catch as e {
        LaunchAppFail("khong chay duoc beckon.exe: " e.Message)
        return
    }
    if (code != 0)
        LaunchAppFail("beckon " name ": exit " code)
}

BeckonHandler(id) => (*) => Beckon(id)

LaunchAppInit() {
    try {
        layers := ShortcutsParse(ShortcutsDir() "apps.toml")
    } catch as e {
        ; KHONG fallback bang cung: tha khong co phim nao con hon chay bang cu
        ; roi tuong da ap dung.
        LaunchAppFail("apps.toml: " e.Message)
        return
    }

    for b in ShortcutsBindings(layers, "app", "windows")
        Hotkey("^#!" b["key"], BeckonHandler(b["id"]))

    for b in ShortcutsBindings(layers, "shift", "windows")
        Hotkey("^#!+" b["key"], BeckonHandler(b["id"]))
}

LaunchAppInit()
