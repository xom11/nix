#Requires AutoHotkey v2.0
#SingleInstance Force

if !A_IsAdmin
{
    Run '*RunAs "' A_AhkPath '" "' A_ScriptFullPath '"'
    ExitApp
}

#Include launch-kanata.ahk
#Include window-manager.ahk
#Include switch-language.ahk
#Include power-manager.ahk

TrayTip "AHK loading sucess!!", "Startup", 1

^#+r:: {
    Reload()
    TrayTip "Reload AHK", "AHK System"
}

KillAll(*) {
    if ProcessExist("kanata.exe")
        ProcessClose("kanata.exe")
    ExitApp()
}