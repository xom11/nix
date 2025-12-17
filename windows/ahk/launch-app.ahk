#Requires AutoHotkey v2.0

LaunchApp(exePath, winTitle ) {
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

; --- GÁN PHÍM TẮT ---
pwaPath := A_Programs . "\Ứng dụng Brave\"

^#!g::LaunchApp(pwaPath . "Google Gemini.lnk", "Google Gemini")
^#!y::LaunchApp(pwaPath . "YouTube.lnk", "YouTube")

; ; Win + Shift + V -> VS Code
; #+v::SmartToggleApp("code.exe")

; ; Win + Shift + T -> Windows Terminal
; #+t::SmartToggleApp("wt.exe")

; ; Win + Shift + N -> Notepad (Ví dụ đường dẫn đầy đủ nếu cần)
; #+n::SmartToggleApp("notepad.exe")