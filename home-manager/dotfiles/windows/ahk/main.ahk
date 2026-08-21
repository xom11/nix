#Requires AutoHotkey v2.0
#SingleInstance Force

; Script lifecycle log.
;
; A dead script is revived within 5 minutes, and each revival fires the "Startup"
; toast below -- so a toast appearing out of nowhere is not a watchdog bug, it is
; the sign the script just died.
;
; The revival is AHKWatchdog's job, not AHKrunning, which now only has a logon
; trigger: a Reload() replaces the process Task Scheduler was watching, so a loop
; living there stopped protecting anything.
;
; Task Scheduler records only an exit code, and 0 covers "replaced by another
; instance", "Reload()", "runtime error" and "quit from the tray menu" alike --
; hence writing ExitReason here.
LogFile() => EnvGet("LOCALAPPDATA") . "\ahk-main.log"

LogLine(msg) {
    try FileAppend(FormatTime(, "yyyy-MM-dd HH:mm:ss") . "  " . msg . "`n", LogFile(), "UTF-8")
}

; A truthy return CANCELS the exit -- must return 0.
OnExitLog(reason, code) {
    LogLine("exit     reason=" . reason . " code=" . code)
    return 0
}

OnExit(OnExitLog)
LogLine("startup  pid=" . DllCall("GetCurrentProcessId"))

#Include lib/ui.ahk
; Focus-or-launch is beckon serve (task \BeckonServe), reading
; configs/shortcuts/launch-app.toml -- edits apply immediately.
#Include evkey-monitor.ahk
#Include caffeine.ahk
#Include ferry.ahk
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
