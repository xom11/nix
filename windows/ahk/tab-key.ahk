#Requires AutoHotkey v2.0

prefix := "^#+"

Hotkey(prefix "t", ShowTime)
Hotkey(prefix "p", ShowBattery)
Hotkey(prefix "r", ReloadConfig)

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

ShowPopup(mainText, subText, accentColor) {
    ui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000")
    ui.BackColor := "21252b"
    ui.MarginX := 20, ui.MarginY := 25

    ui.SetFont("s60 w700 c" accentColor, "Segoe UI Variable Display")
    ui.AddText("Center w450", mainText)

    ui.SetFont("s15 w400 cabb2bf", "Segoe UI Variable Text")
    ui.AddText("Center w450", subText)

    ui.Show("NoActivate")
    ih := InputHook("L1 T3")
    ih.Start(), ih.Wait()
    ui.Destroy()
}
