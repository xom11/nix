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
#!s::SendMessage(0x0112, 0xF170, 2, , "Program Manager")

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