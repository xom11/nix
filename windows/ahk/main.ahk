#Requires AutoHotkey v2.0
#SingleInstance Force


#Include launch-kanata.ahk
#Include launch-app.ahk

TrayTip "Hệ thống AHK đã sẵn sàng!", "Startup", 1

!r:: {
    Reload()
    TrayTip "Reload AHK", "AHK System"
}

KillAll(*) {
    if ProcessExist("kanata.exe")
        ProcessClose("kanata.exe")
    ExitApp()
}