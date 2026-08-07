#Requires AutoHotkey v2.0
#SingleInstance Off

; Two modes, chosen by whoever launches this:
;
;   (no argument)  Force restart. Used by the Kanata task at logon and by evkey-monitor.ahk
;                  after VKey restarts -- there the entire point is to tear kanata down and
;                  bring it back so its WH_KEYBOARD_LL hook re-registers in the right order.
;
;   --if-missing   Start kanata only when it is gone. The KanataWatchdog task runs this on a
;                  timer, and killing a healthy kanata every few minutes would drop keystrokes.
;
; #SingleInstance Off because both tasks run this same file: the v2 default would have one
; invocation kill the other mid-launch.

userDir := EnvGet("USERPROFILE")

; kanata's build name carries the CPU architecture, and the two release zips share NO file:
; windows-binaries-x64.zip ships kanata_windows_tty_winIOv2_x64.exe, windows-binaries-arm64.zip
; ships kanata_windows_tty_winIOv2_arm64.exe. Hardcoding one name here is what forced
; 'kanata=64bit' into scoop's -KeepArchitecture list -- an architecture swap left this launcher
; pointing at a file that no longer existed, on the machine whose keyboard you would need in
; order to fix it. Resolve the name instead of assuming it and the swap stops being dangerous.
;
; arm64 is tried first because a14 is a Snapdragon X; x64 stays as the fallback for any future
; Intel/AMD Windows box sharing this repo. Order only decides which wins if both are somehow
; present, which scoop never does.
global KanataExeNames := ["kanata_windows_tty_winIOv2_arm64.exe", "kanata_windows_tty_winIOv2_x64.exe"]
global KanataDir := userDir . "\scoop\apps\kanata\current\"
global KanataExe := ResolveKanataExe()
global KanataConfig := userDir . "\.nix\configs\kanata\kanata_windows.kbd"

; No build present at all. Historically this path was the quiet one that hurt: the watchdog runs
; every five minutes unattended, so a missing binary produced no window, no log and no keyboard.
; Exit non-zero so Task Scheduler records it -- `Get-ScheduledTaskInfo Kanata` then shows a
; LastTaskResult other than 0, which is the only breadcrumb an unattended run can leave.
if (KanataExe = "") {
    if (!(A_Args.Length >= 1 && A_Args[1] = "--if-missing"))
        MsgBox "Error: no kanata build found in`n" . KanataDir . "`n`nTried:`n- " . ArrayJoin(KanataExeNames, "`n- ")
    ExitApp(2)
}

ResolveKanataExe() {
    global KanataExeNames, KanataDir
    for name in KanataExeNames {
        if FileExist(KanataDir . name)
            return KanataDir . name
    }
    return ""
}

ArrayJoin(arr, sep) {
    out := ""
    for i, v in arr
        out .= (i = 1 ? "" : sep) . v
    return out
}

; --nodelay: kanata otherwise sleeps 2s at startup so that keys held down at launch are released
; before it starts tracking state. Measured on a14 2026-08-07, spawn -> "Starting kanata proper":
;
;     default    2837 ms       --nodelay    102 ms
;
; Every one of those milliseconds is a window where the physical CapsLock is a real CapsLock
; again. That is the whole bug this flag exists to close: press caps+space in the gap and Windows
; toggles caps on, and by the time you reach for it again kanata owns the key and will not give
; it back. The window opens on every logon and on every wake -- evkey-monitor.ahk restarts kanata
; after resume/unlock by design -- so this is worth far more than any tuning of the trigger delay.
; Measured end to end: the wake-time gap goes from ~2.8 s to ~75 ms.
;
; The held-key case the sleep guards against is already covered on both paths: at logon nothing
; is held, and on wake evkey-monitor waits __vk_settleDelay before it even asks for the restart.
global KanataArgs := "--nodelay"

; See WaitForVKey. 30 s is a backstop for "VKey is never coming", not an expected wait.
global VKeyProc := "VKey.exe"
global VKeyAppearTimeoutMs := 30000
global VKeyIdleTimeoutMs := 10000
global VKeyMarginMs := 250

SplitPath(KanataExe, &KanataProc)  ; process name = exe filename, e.g. kanata_..._cmd_allowed_x64.exe

IfMissingOnly := (A_Args.Length >= 1 && A_Args[1] = "--if-missing")

if (IfMissingOnly) {
    if ProcessExist(KanataProc)
        ExitApp(0)
    ; The logon task may be starting kanata this very second. Look again before concluding it
    ; is really gone, otherwise both would launch a copy and the two would fight over the
    ; keyboard hook.
    Sleep(1500)
    if ProcessExist(KanataProc)
        ExitApp(0)
}

StartKanata(IfMissingOnly)
ExitApp(0)

; Block until VKey is far enough along that kanata's hook lands ON TOP of VKey's.
;
; WH_KEYBOARD_LL is a LIFO chain, so kanata has to register last -- evkey-monitor.ahk documents
; what breaks when it does not. The Kanata task used to buy that ordering with a flat PT5S
; trigger delay, and a measurement on a14 (boot of 2026-08-06) showed how thin a guess that was:
; VKey's process did not start until explorer + 4643 ms, because it is entry 6 of 7 in
; HKCU\...\Run and Explorer launches those one at a time, behind OneDrive, Discord, the Brave
; updater, Warp and Lark. Five seconds was not a safety margin so much as a near miss -- and
; shortening kanata's own startup with --nodelay would have eaten what little was left of it.
;
; So wait for the thing itself rather than for the clock. A process cannot service a low-level
; keyboard hook without a message loop, and WaitForInputIdle returns exactly when that loop is up
; and idle. Verified on a14 that it reports SUCCESS for VKey -- but only when called from
; session 1. Over SSH (session 0) the identical call returns WAIT_FAILED, which reads as "VKey
; has no message queue" and is really a cross-session artifact; do not re-measure it that way and
; conclude the signal is unusable. This launcher always runs in the user's session.
;
; What this still does not prove is that VKey installs its hook BEFORE entering its loop rather
; than after. Most apps hook during init, but that is an inference, not a guarantee -- hence the
; margin below. It is the one guess left on this path, and it is 250 ms instead of 5000.
WaitForVKey(appearTimeoutMs) {
    global VKeyProc, VKeyIdleTimeoutMs, VKeyMarginMs

    pid := ProcessExist(VKeyProc)
    if (!pid && appearTimeoutMs > 0)
        pid := ProcessWait(VKeyProc, appearTimeoutMs / 1000)
    ; VKey is not coming. Start kanata anyway: a keyboard with a possibly-wrong hook order still
    ; beats no remapping at all, and evkey-monitor.ahk restarts us if VKey shows up later.
    if (!pid)
        return false

    SYNCHRONIZE := 0x00100000, PROCESS_QUERY_INFORMATION := 0x0400
    h := DllCall("kernel32\OpenProcess", "UInt", SYNCHRONIZE | PROCESS_QUERY_INFORMATION,
                 "Int", 0, "UInt", pid, "Ptr")
    if (h) {
        DllCall("user32\WaitForInputIdle", "Ptr", h, "UInt", VKeyIdleTimeoutMs)
        DllCall("kernel32\CloseHandle", "Ptr", h)
    }
    Sleep(VKeyMarginMs)
    return true
}

StartKanata(quiet := false) {
    global KanataProc, KanataExe, KanataConfig, KanataArgs, VKeyAppearTimeoutMs

    ; Wait for VKey BEFORE tearing the running kanata down, never after. Everything between
    ; ProcessClose and the new hook going live is raw-keyboard time, and that stretch is already
    ; only ~157 ms (measured); putting the VKey wait on the far side of it would hand those
    ; milliseconds back and add the margin on top. On wake VKey has been up for hours so this
    ; returns almost immediately -- at logon it is the entire point.
    ;
    ; The watchdog path deliberately does not wait for VKey to appear: it fires every five
    ; minutes, and a VKey that is genuinely gone would stall every single run for the full
    ; timeout. If VKey comes back later, evkey-monitor.ahk's process-transition branch is what
    ; restarts kanata.
    WaitForVKey(quiet ? 0 : VKeyAppearTimeoutMs)

    if ProcessExist(KanataProc) {
        ProcessClose(KanataProc)
        ProcessWaitClose(KanataProc, 2)
    }

    if GetKeyState("CapsLock", "T") {
        SetCapsLockState "AlwaysOff"
        SetCapsLockState "Off"
    }

    try {
        Run(KanataExe ' -c "' . KanataConfig . '" ' . KanataArgs, , "Hide")
    } catch {
        ; The watchdog runs unattended every few minutes; a MsgBox there would stack up a new
        ; dialog on the desktop each time.
        if (!quiet)
            MsgBox "Error: Kanata config not found!`n`nExe: " . KanataExe . "`nConfig: " . KanataConfig
    }
}
