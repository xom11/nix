#Requires AutoHotkey v2.0
Persistent

; Giu Kanata luon la hook WH_KEYBOARD_LL moi nhat.
;
; Root cause: ca Kanata winIOv2 va VKey deu dung WH_KEYBOARD_LL. Chain la LIFO —
; hook cai SAU duoc goi TRUOC. Kanata phai la hook moi nhat: no an phim vat ly roi
; bom lai phim da remap, nen VKey nam duoi chi thay dong phim cuoi cung, dung thu
; se vao app. Neu VKey thanh hook moi nhat thi no phan ung theo nhung phim ma Kanata
; sau do chan di, cong them ca phim Kanata bom vao — dong phim VKey nhin thay khong
; con khop voi cai that su xay ra.
;
; Cach khoi phuc duy nhat: restart Kanata de hook cua no dang ky lai len tren. Task
; "Kanata" lam viec do (Task Scheduler tu dam bao admin context).
;
; Vi sao phai doan bang su kien thay vi kiem tra truc tiep: user-mode KHONG co API
; nao liet ke chain WH_KEYBOARD_LL. Ta chi bat duoc cac thoi diem VKey CO THE da
; dang ky lai hook, roi dat Kanata len tren mot lan nua:
;
;   1. VKey tu khong-chay sang dang-chay  (chac chan dang ky lai)
;   2. Mo khoa may                        (co the)
;   3. Thuc tu sleep                      (co the)
;
; (2) va (3) truoc day bi bo sot: neu VKey dang ky lai hook ma KHONG restart tien
; trinh thi (1) khong thay gi, thu tu dao am tham va khong co gi sua.
;
; Tren ARM64 (a14-win) khong co duong nao thoat kien truc nay: build wintercept can
; driver kernel x64 cua Interception, ma Windows on ARM khong nap noi driver kernel
; x64 — da xac minh 30/07/2026 (CodeIntegrity 3004 + "The driver \Driver\keyboard
; failed to load"). winIOv2 (LLHOOK) la lua chon duy nhat, nen vong nay la thiet ke
; chu khong phai cha vit tam thoi.

; --- Configuration ---

; Thoi gian poll (ms). VKey restart thuong co gap vai giay.
global __vk_checkInterval := 1000

; Hoan truoc khi restart Kanata o nhanh unlock/resume. Khac nhanh (1) — o do ta da
; BIET VKey vua len nen restart ngay la dung — con o day VKey co the dang ky lai hook
; cham hon ta mot nhip, restart som se bi no chen len tren lai.
global __vk_settleDelay := 2500

; Chan restart trung lap: wake va unlock gan nhu luon ban lien nhau, ma moi lan
; restart Kanata la mot nhip rot phim.
global __vk_debounce := 8000

; --- State ---
global __vk_wasRunning := false
global __vk_firstCheck := true
global __vk_lastRequest := 0

; Xin Windows gui WM_WTSSESSION_CHANGE toi cua so an cua script.
; NOTIFY_FOR_THIS_SESSION = 0.
DllCall("Wtsapi32\WTSRegisterSessionNotification", "Ptr", A_ScriptHwnd, "UInt", 0, "Int")

OnMessage(0x02B1, OnSessionChange)   ; WM_WTSSESSION_CHANGE
OnMessage(0x0218, OnPowerBroadcast)  ; WM_POWERBROADCAST

RequestKanataRestart(delayMs := 0) {
    global __vk_lastRequest, __vk_debounce
    if (A_TickCount - __vk_lastRequest < __vk_debounce)
        return
    __vk_lastRequest := A_TickCount
    if (delayMs > 0)
        SetTimer(RunKanataTask, -delayMs)  ; am = chay dung mot lan
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

    ; Phat hien VKey tu khong-chay sang dang-chay => restart ngay
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

; Tren laptop, thuc tu sleep hau nhu luon keo theo mot lan mo khoa, nen nhanh nay
; chu yeu la lop du phong cho nhanh unlock. Cua so chinh cua AHK bi an nhung van la
; top-level window nen nhan duoc broadcast nay.
OnPowerBroadcast(wParam, lParam, msg, hwnd) {
    global __vk_settleDelay
    static PBT_APMRESUMESUSPEND := 0x7, PBT_APMRESUMEAUTOMATIC := 0x12
    if (wParam = PBT_APMRESUMESUSPEND || wParam = PBT_APMRESUMEAUTOMATIC)
        RequestKanataRestart(__vk_settleDelay)
}

SetTimer(CheckVKey, __vk_checkInterval)
