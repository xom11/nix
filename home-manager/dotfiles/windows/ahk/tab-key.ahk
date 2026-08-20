#Requires AutoHotkey v2.0

tabkey := "^#+"

Hotkey(tabkey "t", ShowTime)
Hotkey(tabkey "p", ShowBattery)
Hotkey(tabkey "r", ReloadConfig)
; Keeps the machine awake while still letting the screen turn off. Same key as
; macOS's Caffeine.spoon but the OPPOSITE meaning -- that one keeps the SCREEN on.
; Reasons at the top of caffeine.ahk.
Hotkey(tabkey "c", ToggleCaffeine)
; Clipboard image -> the machine you are ssh'd into, then types the path at the
; cursor. Why it has to go the long way round is at the top of ferry.ahk.
Hotkey(tabkey "v", FerryImage)
; Input mode: Q = Chinese, W = Vietnamese, E = English. SwitchMode calls `tongue`
; to move BOTH the layout and VKey; this used to call SetInputLang, which reached
; only the layout.
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
    ShowPopup("🔋 " charge, "Status: " status, "98c379")
}

#Include lib/ui.ahk
