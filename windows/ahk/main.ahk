#Requires AutoHotkey v2.0
#SingleInstance Force

if !A_IsAdmin
{
    Run '*RunAs "' A_AhkPath '" "' A_ScriptFullPath '"'
    ExitApp
}

#Include lib/ui.ahk
#Include launch-app.ahk
#Include launch-kanata.ahk
#Include power-manager.ahk
#Include switch-language.ahk
#Include window-manager.ahk
#Include tab-key.ahk
#Include fix-spelling.ahk

TrayTip "AHK loading sucess!!", "Startup", 1

; ^#+r:: {
;     Reload()
;     TrayTip "Reload AHK", "AHK System"
; }

KillAll(*) {
    if ProcessExist("kanata.exe")
        ProcessClose("kanata.exe")
    ExitApp()
}
