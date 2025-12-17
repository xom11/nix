#Requires AutoHotkey v2.0

LaunchApp(exePath, winTitle := "") {
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

^#!g:: LaunchApp(pwaPath . "Google Gemini", "Google Gemini")
^#!y:: LaunchApp(pwaPath . "YouTube", "YouTube")
^#!m:: LaunchApp(pwaPath . "Messenger", "Messenger")
^#!k:: LaunchApp(pwaPath . "Google Keep", "Google Keep")

^#!v:: LaunchApp("code.exe")
^#!t:: LaunchApp("Telegram")

#Include lib/which-key.ahk
menuApps := Map(
    "b", { Desc: "Brave Browser", Action: (*) => LaunchApp("brave.exe") },
    "c", { Desc: "VS Code", Action: (*) => LaunchApp("code.exe") },
    "t", { Desc: "Terminal", Action: (*) => LaunchApp("wt.exe") },
    "s", { Desc: "System Sleep", Action: (*) => DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0) }
)
^#!a:: WhichKey("🚀 Quick Apps", menuApps)