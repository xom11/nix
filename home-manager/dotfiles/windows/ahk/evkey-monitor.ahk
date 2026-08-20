#Requires AutoHotkey v2.0
Persistent

; Keep Kanata as the most recently installed WH_KEYBOARD_LL hook.
;
; Both Kanata's winIOv2 and VKey use that hook, and the chain is LIFO -- the hook
; installed LAST is called FIRST. Kanata must be last: it eats the physical key and
; injects the remapped one, so VKey below it sees only the final key stream. With
; VKey on top, it reacts to keys Kanata then swallows plus the ones Kanata injects,
; and what it sees no longer matches what happens.
;
; The only fix is restarting Kanata so its hook re-registers on top. The "Kanata"
; scheduled task does that, and gives it admin context.
;
; Detection is event-based because user-mode has NO API to enumerate that chain. We
; can only catch moments when VKey MIGHT have re-registered, then put Kanata back:
;   1. VKey goes from not-running to running  (certain)
;   2. Session unlock                         (possible)
;   3. Resume from sleep                      (possible)
; (2) and (3) were once missing, so a VKey that re-hooked WITHOUT restarting flipped
; the order silently with nothing to correct it.
;
; No escape from this on ARM64: wintercept needs Interception's x64 kernel driver,
; which Windows on ARM cannot load (verified: CodeIntegrity 3004). LLHOOK is the only
; option, so this loop is design, not a stopgap.

; --- Configuration ---

; Poll interval (ms). A VKey restart usually has seconds of slack.
global __vk_checkInterval := 1000

; Delay before restarting on the unlock/resume paths. Unlike case (1), where VKey is
; known to have just started, here it may re-register a beat after us -- restarting
; too early just lets it back on top.
global __vk_settleDelay := 2500

; Wake and unlock almost always fire together, and each Kanata restart drops keys.
global __vk_debounce := 8000

; --- State ---
global __vk_wasRunning := false
global __vk_firstCheck := true
global __vk_lastRequest := 0

; Ask Windows for WM_WTSSESSION_CHANGE on the script's hidden window.
DllCall("Wtsapi32\WTSRegisterSessionNotification", "Ptr", A_ScriptHwnd, "UInt", 0, "Int")

OnMessage(0x02B1, OnSessionChange)   ; WM_WTSSESSION_CHANGE
OnMessage(0x0218, OnPowerBroadcast)  ; WM_POWERBROADCAST

RequestKanataRestart(delayMs := 0) {
    global __vk_lastRequest, __vk_debounce
    if (A_TickCount - __vk_lastRequest < __vk_debounce)
        return
    __vk_lastRequest := A_TickCount
    if (delayMs > 0)
        SetTimer(RunKanataTask, -delayMs)  ; negative = run once
    else
        RunKanataTask()
}

RunKanataTask() {
    Run('schtasks /run /tn "Kanata"', , "Hide")
}

CheckVKey() {
    global __vk_wasRunning, __vk_firstCheck

    isRunning := ProcessExist("VKey.exe")

    if (__vk_firstCheck) {
        __vk_wasRunning := isRunning
        __vk_firstCheck := false
        return
    }

    ; not-running -> running means it definitely re-registered
    if (isRunning && !__vk_wasRunning)
        RequestKanataRestart()

    __vk_wasRunning := isRunning
}

OnSessionChange(wParam, lParam, msg, hwnd) {
    global __vk_settleDelay
    static WTS_SESSION_UNLOCK := 0x8
    if (wParam = WTS_SESSION_UNLOCK)
        RequestKanataRestart(__vk_settleDelay)
}

; On a laptop, resume nearly always brings an unlock with it, so this is mostly a
; backstop. AHK's main window is hidden but still top-level, so it gets the broadcast.
OnPowerBroadcast(wParam, lParam, msg, hwnd) {
    global __vk_settleDelay
    static PBT_APMRESUMESUSPEND := 0x7, PBT_APMRESUMEAUTOMATIC := 0x12
    if (wParam = PBT_APMRESUMESUSPEND || wParam = PBT_APMRESUMEAUTOMATIC)
        RequestKanataRestart(__vk_settleDelay)
}

SetTimer(CheckVKey, __vk_checkInterval)
