#Requires AutoHotkey v2.0

tabkey := "^#+"

Hotkey(tabkey "t", ShowTime)
Hotkey(tabkey "p", ShowBattery)
Hotkey(tabkey "r", ReloadConfig)
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
