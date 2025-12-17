#Requires AutoHotkey v2.0

LaunchApp(exePath, winTitle := "" ) {
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

^#!g::LaunchApp(pwaPath . "Google Gemini.lnk", "Google Gemini")
^#!y::LaunchApp(pwaPath . "YouTube.lnk", "YouTube")
^#!b::LaunchApp("brave.exe", "Chrome_WidgetWin_1")
^#!v::LaunchApp("code.exe")


#Include lib/which-key.ahk
#+a:: {
    ; Khai báo danh sách các phím con
    menuApps := Map(
        "b", {Desc: "Brave Browser", Action: (*) => LaunchApp("brave.exe")},
        "c", {Desc: "VS Code",       Action: (*) => LaunchApp("code.exe")},
        "t", {Desc: "Terminal",      Action: (*) => LaunchApp("wt.exe")},
        "s", {Desc: "System Sleep",  Action: (*) => DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)}
    )
    
    ; Gọi hàm hiển thị
    WhichKey("🚀 Quick Apps", menuApps)
}