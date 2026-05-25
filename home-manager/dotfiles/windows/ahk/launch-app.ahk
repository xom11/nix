#Requires AutoHotkey v2.0

Beckon(name) {
    try RunWait('beckon.exe "' name '"', , "Hide")
}

; ── Apps ──
^#!b:: Beckon("Vivaldi")
^#!c:: Beckon("Claude")
^#!d:: Beckon("Discord")
^#!g:: Beckon("Google Gemini")
^#!k:: Beckon("Google Keep")
^#!m:: Beckon("Messenger")
^#!n:: Beckon("Notion")
^#!t:: Beckon("Telegram Web")
^#!y:: Beckon("YouTube")
^#!z:: Beckon("Zalo")
^#!Space:: Beckon("windowsterminal.exe")
^#!f:: {
    if WinExist("ahk_class CabinetWClass") {
        if WinActive("ahk_class CabinetWClass")
            Send("!{Esc}")
        else
            WinActivate("ahk_class CabinetWClass")
    } else {
        Run("explorer.exe")
    }
}

; ── Settings (URI scheme) ──
^#!s:: {
    if !WinExist("ahk_exe ApplicationFrameHost.exe")
        Run("ms-settings:")
    else if WinActive("ahk_exe ApplicationFrameHost.exe")
        Send("!{Esc}")
    else
        WinActivate("ahk_exe ApplicationFrameHost.exe")
}

; ── WhichKey submenu ──
#Include lib/which-key.ahk
menuApps := Map(
    "d", { Desc: "DeepSeek", Action: (*) => Beckon("DeepSeek") },
    "m", { Desc: "Gmail", Action: (*) => Beckon("Gmail") },
    "c", { Desc: "Chrome", Action: (*) => Beckon("Google Chrome") },
    "f", { Desc: "Facebook", Action: (*) => Beckon("Facebook") },
)
^#!a:: WhichKey("🚀 Quick Apps", menuApps)
