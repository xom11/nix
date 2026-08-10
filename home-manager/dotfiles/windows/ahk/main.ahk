#Requires AutoHotkey v2.0
#SingleInstance Force

; Nhat ky vong doi cua script.
;
; Script chet thi duoc hoi sinh trong vong 5 phut -- va moi lan hoi sinh lai bung
; TrayTip "Startup" ben duoi. Nghia la toast tu nhien hien ra giua chung khong
; phai loi cua watchdog: no la dau hieu script vua chet.
;
; Viec hoi sinh do task AHKWatchdog lam (chay launch-ahk.ahk voi --if-missing moi
; 5 phut), KHONG phai task AHKrunning -- AHKrunning chi con dung mot logon trigger.
; Truoc 30/07/2026 nhip lap do nam trong AHKrunning that, nhung no ngung bao ve
; duoc bat cu thu gi ngay khi Reload() thay the tien trinh ma Task Scheduler dang
; theo doi; ly do day du nam trong windows\modules\services\ahk-watchdog.
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
; Focus-or-launch: beckon serve (task \BeckonServe), du lieu configs/shortcuts/apps.windows.toml — sua la an ngay.
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
