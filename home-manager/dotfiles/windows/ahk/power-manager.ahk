#Requires AutoHotkey v2.0

; Lock Workstation
#!l::DllCall("LockWorkStation")

; Sleep
;
; SetSuspendState never worked here: a14 has exactly one sleep state, S0 Low
; Power Idle, and that API belongs to the S3 era -- it returns 0 with
; ERROR_NOT_SUPPORTED, silently, with no error or toast. (Kernel-Power event 42
; has never appeared on this machine; only 506/507, modern standby.)
;
; The only way a user-mode app reaches modern standby is turning the display
; off: Windows drifts into S0 seconds later. Only works from the user's session.
;
;   0x0112 = WM_SYSCOMMAND, 0xF170 = SC_MONITORPOWER, lParam 2 = off.
;
; Waiting for keys to be released is REQUIRED, not politeness. Measured: sending
; the message directly did enter standby, then got kicked out ~0.85 s later with
; reason "Input Keyboard" -- six occurrences across four days landed within
; 35 ms of each other, so this is a FIXED system window, not slow fingers:
; Windows blocks input briefly after entering standby, and whatever arrives in
; that window is queued and fires the moment the block lifts. Sessions entered by
; idle timeout instead stayed asleep for hours, and the only difference is
; whether a key was held.
;
; The timeout exists so a stuck key (kanata holding a modifier) degrades to the
; old behaviour rather than refusing to sleep.
;
; THE KEYBOARD IS NOT THE ONLY SOURCE: the next press, the one where the lid was
; closed, bounced after 934 ms with reason "Input Touchpad" -- same fixed window,
; different device. Reaching over the palm rest to close the lid brushes it.
; Hence also waiting for the pointer to be STILL: what matters is the passing
; touch, which produces movement and resets the clock. A finger resting perfectly
; still would NOT be caught; if touchpad wake-ups return, switch to watching the
; lid-close event rather than guessing further.
SleepWaitAllKeysUpMs := 3000
SleepPointerQuietMs := 600
SleepPointerWaitMs := 6000
SleepSettleMs := 250

WaitAllKeysUp(timeoutMs) {
    static keys := ["LWin", "RWin", "LAlt", "RAlt", "LCtrl", "RCtrl"
                  , "LShift", "RShift", "s"
                  , "LButton", "RButton", "MButton"]
    deadline := A_TickCount + timeoutMs
    loop {
        anyDown := false
        for k in keys {
            if GetKeyState(k, "P") {
                anyDown := true
                break
            }
        }
        if (!anyDown)
            return true
        if (A_TickCount > deadline)
            return false
        Sleep(20)
    }
}

; true once the pointer has been still for quietMs, false on timeout -- both go
; ahead anyway, same as WaitAllKeysUp.
WaitPointerStill(quietMs, timeoutMs) {
    deadline := A_TickCount + timeoutMs
    MouseGetPos(&lastX, &lastY)
    stillSince := A_TickCount
    loop {
        Sleep(20)
        MouseGetPos(&x, &y)
        if (x != lastX || y != lastY) {
            lastX := x
            lastY := y
            stillSince := A_TickCount
        }
        if (A_TickCount - stillSince >= quietMs)
            return true
        if (A_TickCount > deadline)
            return false
    }
}

#!s:: {
    global SleepWaitAllKeysUpMs, SleepPointerQuietMs, SleepPointerWaitMs
    global SleepSettleMs
    WaitAllKeysUp(SleepWaitAllKeysUpMs)
    WaitPointerStill(SleepPointerQuietMs, SleepPointerWaitMs)
    Sleep(SleepSettleMs)
    SendMessage(0x0112, 0xF170, 2, , "Program Manager")
}

; Lock out 
+#!L:: {
    if MsgBox("Sign out?", "Logoff", 4) = "Yes"
        Shutdown 0
}

; Restart
+#!r:: {
    if MsgBox("Restart computer?", "Reboot", 4) = "Yes"
        Shutdown 2
}

; Shutdown
+#!s:: {
    if MsgBox("Shutdown computer?", "Power Off", 4) = "Yes"
        Shutdown 1
}