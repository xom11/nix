#Requires AutoHotkey v2.0
#SingleInstance Force

; Nhat ky vong doi cua script.
;
; Task AHKrunning co mot trigger lap moi 5 phut lam watchdog, nen script chet la
; duoc hoi sinh trong vong 5 phut -- va moi lan hoi sinh lai bung TrayTip
; "Startup" ben duoi. Nghia la toast tu nhien hien ra giua chung khong phai loi
; cua watchdog: no la dau hieu script vua chet.
;
; Task Scheduler chi ghi lai exit code, ma exit code 0 gop chung ca "bi instance
; khac thay the", "Reload()", "loi runtime" lan "thoat tu menu tray". Khong tach
; duoc bang exit code, nen phai tu ghi ExitReason.
LogFile() => EnvGet("LOCALAPPDATA") . "\ahk-main.log"

LogLine(msg) {
    try FileAppend(FormatTime(, "yyyy-MM-dd HH:mm:ss") . "  " . msg . "`n", LogFile(), "UTF-8")
}

; Tra ve gia tri that se HUY viec thoat -- phai tra ve 0.
OnExitLog(reason, code) {
    LogLine("exit     reason=" . reason . " code=" . code)
    return 0
}

OnExit(OnExitLog)
LogLine("startup  pid=" . DllCall("GetCurrentProcessId"))

#Include lib/ui.ahk
#Include launch-app.ahk
#Include evkey-monitor.ahk
#Include power-manager.ahk
#Include switch-language.ahk
#Include window-manager.ahk
#Include tab-key.ahk

TrayTip "AHK loading sucess!!", "Startup", 1

; ^#+r:: {
;     Reload()
;     TrayTip "Reload AHK", "AHK System"
; }

KillAll(*) {
    ExitApp()
}
