#Requires AutoHotkey v2.0

Beckon(name) {
    try RunWait('beckon.exe "' name '"', , "Hide")
}

; ── Apps ──
^#!b:: Beckon("Brave Browser")
^#!c:: Beckon("Claude")
^#!d:: Beckon("Discord")
^#!g:: Beckon("Google Gemini")
^#!k:: Beckon("Google Keep")
^#!m:: Beckon("Messenger")
^#!n:: Beckon("Notion")
^#!t:: Beckon("Telegram Web")
^#!y:: Beckon("YouTube")
^#!z:: Beckon("Zalo")
^#!Space:: Beckon("Terminal")
^#!f:: Beckon("File Explorer")
^#!s:: Beckon("Settings") 
; ── WhichKey submenu ──
#Include lib/which-key.ahk
menuApps := Map(
    "d", { Desc: "DeepSeek", Action: (*) => Beckon("DeepSeek") },
    "b", { Desc: "Brave", Action: (*) => Beckon("Brave") },
    "m", { Desc: "Gmail", Action: (*) => Beckon("Gmail") },
    "c", { Desc: "Chrome", Action: (*) => Beckon("Google Chrome") },
    "f", { Desc: "Facebook", Action: (*) => Beckon("Facebook") },
)
^#!a:: WhichKey("🚀 Quick Apps", menuApps)
