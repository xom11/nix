#Requires AutoHotkey v2.0
#SingleInstance Force


#Include kanata.ahk
#Include launch-app.ahk

TrayTip "Hệ thống AHK đã sẵn sàng!", "Startup", 1

!r:: {
    TrayTip "Reload AHK", "AHK System"
    Reload()
}

KillAll(*) {
    if ProcessExist("kanata.exe")
        ProcessClose("kanata.exe")
    ExitApp()
}