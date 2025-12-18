#Requires AutoHotkey v2.0
SetTitleMatchMode 3 ; Exact title match

Launch(exePath, winTitle := "", matchMode := 3) {
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

Snap(winTitle, state) {
    WinRestore(winTitle)

    MonitorGetWorkArea(1, &L, &T, &R, &B)
    W := R - L
    H := B - T

    if (state = "Max") {
        WinMaximize(winTitle)
    }
    else if (state = "Left") {
        ; X: Left, Y: Top, W: 1/2 Width, H: Full Height
        WinMove(L, T, W / 2, H, winTitle)
    }
    else if (state = "Right") {
        ; X: Left + 1/2 Width, Y: Top, W: 1/2 Width, H: Full Height
        WinMove(L + W / 2, T, W / 2, H, winTitle)
    }
}

^#!,:: Snap("A", "Left")
^#!.:: Snap("A", "Right")
^#!/:: Snap("A", "Max")

pwaPath := A_Programs . "\Ứng dụng Brave\"
LocalAppData := EnvGet("LocalAppData")

^#!g:: Launch(pwaPath . "Google Gemini.lnk", "Google Gemini")
^#!y:: Launch(pwaPath . "YouTube.lnk", "YouTube", 2)
^#!m:: Launch(pwaPath . "Messenger.lnk", "Messenger")
^#!k:: Launch(pwaPath . "Google Keep.lnk", "Google Keep")

^#!v:: Launch("code.exe")
^#!b:: Launch("brave.exe", " - Brave", 2)
^#!t:: Launch("tg://", "ahk_exe Telegram.exe")
^#!d:: Launch("discord://", "ahk_exe Discord.exe")
^#!n:: Launch("notion://", "ahk_exe Notion.exe")
^#!Space:: Launch("wt", "ahk_exe WindowsTerminal.exe")
^#!f:: Launch("explorer", "ahk_class CabinetWClass")
^#!s:: Launch("ms-settings:", "ahk_exe ApplicationFrameHost.exe")

^#!z:: Launch(LocalAppData . "\Programs\Zalo\Zalo.exe", "ahk_exe zalo.exe")

#Include lib/which-key.ahk
menuApps := Map(
    "d", { Desc: "DeepSeek", Action: (*) => 
        Launch(pwaPath . "DeepSeek - Into the Unknown.lnk", "DeepSeek - Into the Unknown", 2) },
    "m", { Desc: "Gmail", Action: (*) =>
        Launch(pwaPath . "Gmail.lnk", "Gmail", 2) },
    "c", { Desc: "Chrome", Action: (*) =>
        Launch("chrome.exe", " - Google Chrome", 2) },
)
^#!a:: WhichKey("🚀 Quick Apps", menuApps)