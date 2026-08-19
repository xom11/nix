#Requires AutoHotkey v2.0

; Lock Workstation
#!l::DllCall("LockWorkStation")

; Sleep
;
; Cho nay tung goi PowrProf\SetSuspendState va no khong bao gio ngu duoc.
; a14 chi con MOT trang thai ngu: S0 Low Power Idle. S1/S2/S3 deu tat vi may ho
; tro modern standby (S3 con bi Device Guard chan them, VBS dang bat), hibernate
; cung khong bat -- `powercfg /a` noi het. Ma SetSuspendState la API cua thoi
; S3: tren may modern standby no tra ve 0 kem GetLastError 50
; (ERROR_NOT_SUPPORTED). Do tren a14 dung ra vay.
;
; Hong kieu im lang: khong loi, khong toast, khong gi ca -- nen rat de doan nham
; sang huong hotkey khong ban hay kanata an mat to hop. Muon kiem lai thi xem
; event Kernel-Power: 42 (ngu S3/S4) chua tung xuat hien tren may nay, chi co
; 506/507 (vao/ra modern standby).
;
; Cach duy nhat de ung dung user-mode dua may vao modern standby la tat man
; hinh; Windows tu troi vao S0 low power idle vai giay sau, dung nhu khi bam
; Sleep tren Start menu. Chi lam duoc tu session cua nguoi dung -- AHK o session
; 1 nen on, service o session 0 thi khong.
;
;   0x0112 = WM_SYSCOMMAND, 0xF170 = SC_MONITORPOWER, lParam 2 = tat han.
;
; PHAI cho nha het phim TRUOC khi tat man hinh, va day khong phai lam dep.
; Do tren a14 19/08/2026: SendMessage thang thi may VAO modern standby that
; (Kernel-Power 506 co ban), roi bi da ra sau ~0.85 s voi ly do "Input Keyboard".
; Bay ngay nhat ky co dung sau phien kieu do, khoang cach 506->507 lan luot
; 832, 834, 835, 852, 861, 867 ms -- sau lan, bon ngay khac nhau, lech ca thay
; 35 ms. Nguoi thi khong nha phim deu den vay; do la mot moc CO DINH cua he
; thong: Windows chan input mot khoang sau khi vao standby, input den trong
; khoang do bi treo lai roi ban ra dung luc het chan.
;
; Doi chieu de chac: moi phien vao ngu bang HET GIO NHAN ROI (`Video Idle
; Timeout`, thay trong `powercfg /sleepstudy /xml`) deu O LAI -- 22 phut, 72
; phut, mot phien 24 tieng. Chi phien do phim tat kich moi bat ra o ~0.85 s.
; Khac nhau duy nhat giua hai duong la luc tat man hinh co phim dang giu hay
; khong.
;
; Nen cho toi khi khong con phim nao xuong roi moi tat man hinh: khong con su
; kien ban phim nao sau moc vao standby thi khong co gi de danh thuc.
;
; Timeout la de khong bao gio ket cung: mot phim ket (kanata giu modifier chang
; han) thi sau 3 s van tat man hinh -- xau nhat la quay ve dung hanh vi cu chu
; khong tu choi ngu.
;
; VA BAN PHIM KHONG PHAI NGUON DUY NHAT -- do tiep cung ngay, ngay sau khi ban
; tren an. Cho nha phim xong thi mot phien ngu duoc 5 phut 06 giay (16:23:11 ->
; 16:28:18), lan dau trong bay ngay mot phien do phim tat kich ma o lai. Nhung
; lan bam ke tiep, lan co GAP NAP, lai bat ra sau 934 ms voi ly do "Input
; Touchpad" -- van dung cai cua so chan co dinh do, chi doi thiet bi. Tay voi
; qua chieu nghi de ha nap la cham touchpad.
;
; Nen cho them: con tro phai DUNG YEN mot khoang truoc khi tat man hinh. Doi
; tuong that su can tranh la cu cham thoang qua luc voi tay, va no sinh ra
; chuyen dong -- moi lan doi toa do la dat lai dong ho. Ngon tay dat im khong
; nhuc nhich thi cach nay KHONG thay; neu con bat ra vi touchpad nua thi phai
; chuyen huong sang bat su kien nap dong, dung doan them.
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

; Tra ve true khi con tro da dung yen du quietMs, false khi het timeoutMs ma van
; con nhuc nhich -- ca hai truong hop deu di tiep, y het WaitAllKeysUp.
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