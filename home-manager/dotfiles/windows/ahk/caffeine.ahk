#Requires AutoHotkey v2.0

; --- === Caffeine ===
;
; Giu may khong ngu, kem mot cham ☕ o goc tren ben phai de biet dang bat.
; Noi phim o tab-key.ahk (Tab+c), doi phim thi sua ben do.
;
; Doi ung cua LibSpoons\Caffeine.spoon ben macOS, NHUNG khong cung nghia --
; va cho khac nhau moi la ly do file nay ton tai:
;
;   macOS   hs.caffeinate.set("displayIdle")  -> giu MAN HINH sang
;   day     ES_SYSTEM_REQUIRED, khong co display -> man hinh VAN TAT
;
; Vi tren a14 khong co lua chon nao khac. `powercfg /a` chi liet ke mot trang
; thai ngu duy nhat: Standby (S0 Low Power Idle) *Network Disconnected*; ban giu
; mang nam o muc khong kha dung, ly do ghi thang la "Connectivity in standby is
; disabled by policy". Nen he may ngu la Tailscale rung va SSH dut, khong co cua
; nao vua ngu vua giu mang. Thu can giu la MAY, khong phai man hinh.
;
; Va no khong thua: power-manager.ahk (#!s) do duoc rang tren may nay tat man
; hinh la Windows tu troi vao S0 low power idle vai giay sau. Power request nay
; chinh la thu chan duong troi do, nen "man hinh tat ma may van chay" chi ton tai
; khi cai nay dang bat.
;
; DUNG bat kem Keep Awake cua look: no dat
; ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED
; (qactions/controls/keepawake_windows.rs), co ca co display, nen no se thang va
; man hinh khoa sang nguyen dem -- dung thu vua tranh o day.
;
; Nguon chan ly de kiem la `powercfg /requests`, khong phai cai cham:
;   SYSTEM:  phai co [PROCESS] ...AutoHotkey64.exe
;   DISPLAY: phai la None.

; Mot bien co thuong la DU o day, va day la cho khac Caffeine.spoon lan thu hai.
; Spoon phai hoi thang he thong vi hs.reload() go sleep prevention ma bien co thi
; song sot qua lan reload -> lech. O AHK thi request do CHINH tien trinh nay giu:
; Reload() hay script chet la Windows go request, dong thoi bien nay sinh lai
; false. Hai thu chet cung nhau nen khong lech duoc.
CaffeineOn := false
CaffeineDot := ""

ToggleCaffeine(*) {
    global CaffeineOn
    CaffeineSet(!CaffeineOn)
}

CaffeineSet(on) {
    global CaffeineOn, CaffeineDot

    ; ES_CONTINUOUS (0x80000000) giu yeu cau cho toi khi go, thay vi chi day lui bo
    ; dem nhan roi dung mot lan. ES_SYSTEM_REQUIRED (0x1) la yeu cau "dung ngu".
    ; ES_DISPLAY_REQUIRED (0x2) CO Y vang mat -- xem dau file.
    ;
    ; Tra ve 0 la that bai; khac 0 la trang thai truoc do, khong phai loi.
    flags := on ? 0x80000001 : 0x80000000
    if (DllCall("kernel32\SetThreadExecutionState", "UInt", flags, "UInt") = 0) {
        TrayTip "SetThreadExecutionState that bai", "Caffeine", 3
        return
    }

    CaffeineOn := on
    if (on)
        CaffeineShowDot()
    else if (CaffeineDot != "")
        CaffeineDot.Hide()
}

CaffeineShowDot() {
    global CaffeineDot

    if (CaffeineDot = "") {
        ; E0x08000000 = WS_EX_NOACTIVATE (khong cuop focus),
        ; E0x20 = WS_EX_TRANSPARENT (chuot bam xuyen qua, khong che thu ben duoi).
        CaffeineDot := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000 +E0x20")
        CaffeineDot.BackColor := "ff4019"
        CaffeineDot.MarginX := 0, CaffeineDot.MarginY := 0
        CaffeineDot.SetFont("s13", "Segoe UI Emoji")
        CaffeineDot.AddText("Center w30 h30 +0x200 BackgroundTrans", "☕")
    }

    ; Tinh lai toa do MOI LAN hien, khong phai mot lan luc nap. Bai hoc chep tu
    ; Caffeine.spoon: ban cu dung trong Tab.spoon dat cham theo man hinh luc load,
    ; nen cam/rut man hinh hay doi do phan giai la cham nam sai cho, co khi ra han
    ; ngoai vung nhin thay.
    MonitorGetWorkArea(MonitorGetPrimary(), &left, &top, &right, &bottom)
    x := right - 30 - 6
    y := top + 6

    CaffeineDot.Show("NoActivate x" x " y" y " w30 h30")
    ; Bo goc, cho giong cham bo tron ben macOS (roundedRectRadii 9).
    WinSetRegion("0-0 w30 h30 R9-9", CaffeineDot.Hwnd)
}
