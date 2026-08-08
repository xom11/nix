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

    ; Hotkey() co the throw neu key khong phai ten phim AHK hop le -- vd
    ; key = "comma" la keysym xkb hop le (sway) va token dconf hop le (GNOME)
    ; nhung AHK khong nhan, nen sync.sh, parse_test.lua, dump.nix, check-
    ; consumers.sh va shortcutsParse.Tests.ps1 deu qua (Pester chi DUMP, khong
    ; BIND). Loi chi lo ra tren may that. main.ahk #Include file nay dau tien
    ; trong cac include co chuc nang (ngay sau lib/ui.ahk chi dinh nghia UI
    ; goi lai) -- mot throw khong bat o day chet ca luong auto-execute, keo
    ; theo evkey-monitor.ahk, power-manager.ahk, switch-language.ahk,
    ; window-manager.ahk, tab-key.ahk va ca toast khoi dong khong bao gio
    ; chay. AHK watchdog khong cuu duoc vi tien trinh van song sau hop thoai
    ; loi. Boc rieng tung Hotkey() de mot key hong chi mat mot binding.
    for b in ShortcutsBindings(layers, "app", "windows") {
        try
            Hotkey("^#!" b["key"], BeckonHandler(b["id"]))
        catch as e
            LaunchAppFail("bind phim " b["key"] " (app): " e.Message)
    }

    for b in ShortcutsBindings(layers, "shift", "windows") {
        try
            Hotkey("^#!+" b["key"], BeckonHandler(b["id"]))
        catch as e
            LaunchAppFail("bind phim " b["key"] " (shift): " e.Message)
    }
}

LaunchAppInit()
