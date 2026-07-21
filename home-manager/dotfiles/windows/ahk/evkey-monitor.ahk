#Requires AutoHotkey v2.0
Persistent

; Monitor VKey process (PhatMT97/VKey — winget install PhatMT97.VKey).
; Khi VKey restart (process PID moi xuat hien), chay scheduled task "Kanata"
; de kill va restart Kanata, khoi phuc hook order.
;
; Root cause: Kanata winIOv2 va VKey deu dung WH_KEYBOARD_LL hook tren Windows.
; Hook chain la LIFO — thang chay sau duoc goi truoc. Khi VKey restart, hook
; order bi thay doi, VKey khong nhan keyboard input dung. Restart Kanata qua
; scheduled task lap lai hook order (Kanata sau VKey).

; --- Configuration ---
global VKeyProc := "VKey.exe"

; Track tat ca VKey PIDs da biet
global __vk_knownPIDs := Map()
global __vk_initialized := false

; Lay tat ca PID cua VKey.exe dang chay (dung WMI)
GetVKeyPIDs() {
    pids := []
    try {
        wmi := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
        results := wmi.ExecQuery("SELECT ProcessId FROM Win32_Process WHERE Name = '" VKeyProc "'")
        for item in results {
            pids.Push(item.ProcessId)
        }
    }
    return pids
}

CheckVKey() {
    global __vk_knownPIDs, __vk_initialized, VKeyProc

    currentPIDs := GetVKeyPIDs()
    if (currentPIDs.Length = 0) {
        ; VKey khong chay, reset known set
        __vk_knownPIDs := Map()
        __vk_initialized := false
        return
    }

    if (!__vk_initialized) {
        ; Lan dau: ghi nhan tat ca PID hien co
        __vk_knownPIDs := Map()
        for _, pid in currentPIDs {
            __vk_knownPIDs.Set(pid, true)
        }
        __vk_initialized := true
        return
    }

    ; Kiem tra co PID moi khong
    hasNewPID := false
    for _, pid in currentPIDs {
        if !__vk_knownPIDs.Has(pid) {
            hasNewPID := true
            __vk_knownPIDs.Set(pid, true)
        }
    }

    if (hasNewPID) {
        ; VKey da restart — restart Kanata de fix hook chain
        Run('schtasks /run /tn "Kanata"', , "Hide")
    }
}

; Kiem tra moi 2 giay
SetTimer(CheckVKey, 2000)
