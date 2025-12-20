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

; Maximize / Half left / Half right window
; Fix for invisible borders when snapping
Snap(winTitle, state) {
    if !hWnd := WinExist(winTitle)
        return

    WinRestore(hWnd)
    
    ; 1. Get the visible frame offset using DWM
    RECT := Buffer(16)
    DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", hWnd, "UInt", 9, "Ptr", RECT, "UInt", 16)
    
    WinGetPos(&X, &Y, , , hWnd)
    offset := NumGet(RECT, 0, "Int") - X

    ; 2. Get Work Area
    MonitorGetWorkArea(1, &L, &T, &R, &B)
    W := R - L
    H := B - T

    ; 3. Snap Logic
    if (state = "Max") {
        WinMaximize(hWnd)
    }
    else if (state = "Left") {
        ; Adjust position and width to compensate for invisible borders
        WinMove(L - offset, T, (W / 2) + (2 * offset), H + offset, hWnd)
    }
    else if (state = "Right") {
        ; Adjust X to start exactly at mid-screen minus offset
        WinMove(L + (W / 2) - offset, T, (W / 2) + (2 * offset), H + offset, hWnd)
    }
}

^#!,:: Snap("A", "Left")
^#!.:: Snap("A", "Right")
^#!/:: Snap("A", "Max")

pwaPath := A_Programs . "\Ứng dụng Brave\"
LocalAppData := EnvGet("LocalAppData") . "\"

^#!g:: Launch(pwaPath . "Google Gemini.lnk", "Google Gemini")
^#!y:: Launch(pwaPath . "YouTube.lnk", "YouTube", 2)
^#!m:: Launch(pwaPath . "Messenger.lnk", "Messenger")
^#!k:: Launch(pwaPath . "Google Keep.lnk", "Google Keep")

^#!v:: Launch("vscode://", "ahk_exe Code.exe")
^#!b:: Launch(LocalAppData . "BraveSoftware\Brave-Browser\Application\brave.exe", " - Brave", 2)
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