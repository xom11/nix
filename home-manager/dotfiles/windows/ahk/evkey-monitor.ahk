#Requires AutoHotkey v2.0
Persistent

; Monitor VKey process (PhatMT97/VKey — winget install PhatMT97.VKey).
;
; Khi VKey tat va chay lai, trigger scheduled task "Kanata" de kill
; va restart Kanata (Task Scheduler tu dam bao admin context).
; Viec nay khoi phuc WH_KEYBOARD_LL hook order giua Kanata vs VKey.
;
; Root cause: ca Kanata winIOv2 va VKey deu dung WH_KEYBOARD_LL hook.
; Hook chain la LIFO — khi VKey restart, hook order bi thay doi,
; VKey khong nhan keyboard input dung.

; --- Configuration ---

; Thoi gian poll (ms). VKey restart thuong co gap vai giay.
global __vk_checkInterval := 1000

; --- State ---
global __vk_wasRunning := false
global __vk_firstCheck := true

CheckVKey() {
    global __vk_wasRunning, __vk_firstCheck

    isRunning := ProcessExist("VKey.exe")

    if (__vk_firstCheck) {
        __vk_wasRunning := isRunning
        __vk_firstCheck := false
        return
    }

    ; Phat hien VKey tu khong-chay sang dang-chay => restart
    if (isRunning && !__vk_wasRunning) {
        Run('schtasks /run /tn "Kanata"', , "Hide")
    }

    __vk_wasRunning := isRunning
}

SetTimer(CheckVKey, __vk_checkInterval)
