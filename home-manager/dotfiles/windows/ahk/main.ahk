#Requires AutoHotkey v2.0
#SingleInstance Force

#Include lib/ui.ahk
#Include launch-app.ahk
#Include evkey-monitor.ahk
#Include power-manager.ahk
#Include switch-language.ahk
#Include window-manager.ahk
#Include tab-key.ahk

TrayTip "AHK loading sucess!!", "Startup", 1

; ^#+r:: {
;     Reload()
;     TrayTip "Reload AHK", "AHK System"
; }

KillAll(*) {
    ExitApp()
}
