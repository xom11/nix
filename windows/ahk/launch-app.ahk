#Requires AutoHotkey v2.0
SetTitleMatchMode 3 ; Exact title match

LaunchApp(exePath, winTitle := "", matchMode := 3) {
    SetTitleMatchMode matchMode

    if (winTitle = "")
        winTitle := "ahk_exe " . exePath

    if !WinExist(winTitle) {
        try {
            Run(exePath)
            if WinWait(winTitle, , 5)
                WinActivate(winTitle)
        } catch {
            MsgBox ": " . exePath
        }
    } else {
        if WinActive(winTitle)
        ; WinMinimize(winTitle)
        ; Send("!{Tab}")
            Send("!{Esc}")
        else
            WinActivate(winTitle)
    }
}

pwaPath := A_Programs . "\Ứng dụng Brave\"

^#!g:: LaunchApp(pwaPath . "Google Gemini.lnk", "Google Gemini")
^#!y:: LaunchApp(pwaPath . "YouTube.lnk", "YouTube")
^#!m:: LaunchApp(pwaPath . "Messenger.lnk", "Messenger")
^#!k:: LaunchApp(pwaPath . "Google Keep.lnk", "Google Keep")

^#!v:: LaunchApp("code.exe")
^#!b:: LaunchApp("brave.exe", " - Brave", 2)
^#!t:: LaunchApp("tg://", "Telegram")
^#!f:: LaunchApp("explorer", "ahk_class CabinetWClass")
^#!s:: LaunchApp("ms-settings:", "ahk_exe ApplicationFrameHost.exe")

#Include lib/which-key.ahk
menuApps := Map(
    "b", { Desc: "Brave Browser", Action: (*) => LaunchApp("brave.exe") },
    "c", { Desc: "VS Code", Action: (*) => LaunchApp("code.exe") },
    "t", { Desc: "Terminal", Action: (*) => LaunchApp("wt.exe") },
    "s", { Desc: "System Sleep", Action: (*) => DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0) }
)
^#!a:: WhichKey("🚀 Quick Apps", menuApps)