#Requires AutoHotkey v2.0

tabkey := "^#+"

Hotkey(tabkey "t", ShowTime)
Hotkey(tabkey "p", ShowBattery)
Hotkey(tabkey "r", ReloadConfig)
; Doi che do go - Tab+Q=Trung, Tab+W=Viet, Tab+E=English.
; SwitchMode nam trong switch-language.ahk, goi `tongue` de gat CA layout lan
; VKey. Truoc day cho nay goi thang SetInputLang, tuc chi doi duoc layout --
; xem comment dau switch-language.ahk.
Hotkey(tabkey "q", (*) => SwitchMode("zh"))
Hotkey(tabkey "w", (*) => SwitchMode("vi"))
Hotkey(tabkey "e", (*) => SwitchMode("en"))
^#+s::Send "+#s"

ReloadConfig(*) {
    Reload()
    TrayTip "Reload AHK", "AHK System"
}
ShowTime(*) {
    time := FormatTime(, "HH:mm:ss")
    date := FormatTime(, "dddd, MMMM dd, yyyy")
    ShowPopup(time, date, "61afef")
}

ShowBattery(*) {
    charge := "N/A", status := "Unknown"
    for battery in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Battery") {
        charge := battery.EstimatedChargeRemaining "%"
        status := (battery.BatteryStatus = 2) ? "Charging" : "Discharging"
    }
    ShowPopup("?? " charge, "Status: " status, "98c379")
}

#Include lib/ui.ahk
