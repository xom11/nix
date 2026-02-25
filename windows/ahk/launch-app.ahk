#Requires AutoHotkey v2.0
SetTitleMatchMode 2 ; Exact 3, Relative 2 

Launch(exePath, winTitle, args := "") {

    if !WinExist(winTitle) {
        try {
            RunAsUser(exePath, args)
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

RunAsUser(target, args := "", workingDir := "") {
    try {
        ; Get the Shell's folder view object
        shellFolderView := ObjBindMethod(ComObject("Shell.Application").Windows.FindWindowSW(0, 0, 8, 0, 1).Document, "Application")
        ; Use ShellExecute to run the target as the user
        shellFolderView().ShellExecute(target, args, workingDir, "open", 1)
    } catch {
        Run(args ? target . ' ' . args : target)
    }
}


; A_programs C:\Users\<User>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs
; LocalAppData C:\Users\<User>\AppData\Local\Microsoft
; A_ProgramsCommon C:\ProgramData\Microsoft\Windows\Start Menu\Programs
LocalAppData := EnvGet("LocalAppData") 
brower := A_Programs . "\Brave.lnk"

^#!b:: Launch(brower, "Brave")
^#!g:: Launch(brower, "Google Gemini", " --app=https://gemini.google.com")
^#!y:: Launch(brower, "YouTube", " --app=https://www.youtube.com")
^#!m:: Launch(brower, "Messenger", " --app=https://www.messenger.com")
^#!k:: Launch(brower, "Google Keep", " --app=https://keep.google.com")
^#!d:: Launch(brower, "Discord", " --app=https://discord.com/app")
^#!t:: Launch(brower, "Telegram", " --app=https://web.telegram.org")
^#!n:: Launch(brower, "Notion", " --app=https://www.notion.so/")
^#!c:: Launch(brower, "Claude", " --app=https://claude.ai/new")

; ^#!t:: Launch(A_Programs . "\Telegram Desktop\Telegram.lnk", "ahk_exe Telegram.exe")
; ^#!d:: Launch(A_Programs . "\Discord Inc\Discord.lnk", "ahk_exe Discord.exe")
; ^#!n:: Launch(A_Programs . "\Notion.lnk", "ahk_exe Notion.exe")

; ^#!v:: Launch(A_Programs . "\Visual Studio Code\Visual Studio Code.lnk", "ahk_exe Code.exe")
^#!z:: Launch(A_Programs . "\Zalo.lnk", "ahk_exe zalo.exe")
; ^#!Space:: Launch(LocalAppData . "\Microsoft\WindowsApps\wt.exe", "ahk_exe WindowsTerminal.exe")
^#!Space:: Launch("wezterm-gui.exe", "ahk_exe wezterm-gui.exe")
^#!f:: Launch("explorer.exe", "ahk_class CabinetWClass")
^#!s:: Launch("ms-settings:", "ahk_exe ApplicationFrameHost.exe")


#Include lib/which-key.ahk
menuApps := Map(
    "d", { Desc: "DeepSeek", Action: (*) =>
        Launch(brower, "DeepSeek", " --app=https://chat.deepseek.com/") },
    "m", { Desc: "Gmail", Action: (*) =>
        Launch(brower, "Gmail", " --app=https://mail.google.com/") },
    "c", { Desc: "Chrome", Action: (*) =>
        Launch(A_ProgramsCommon . "\Google Chrome.lnk", "Google Chrome") },
)
^#!a:: WhichKey("🚀 Quick Apps", menuApps)
