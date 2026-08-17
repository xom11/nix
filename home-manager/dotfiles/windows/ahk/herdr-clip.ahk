#Requires AutoHotkey v2.0

; --- === Herdr clip ===
;
; Chup man hinh o day, bam Tab+v, duong dan anh hien ra trong pane Claude dang
; focus ben macmini. Noi phim o tab-key.ahk (Tab+v), doi phim thi sua ben do.
; Di lien voi Tab+s ngay ben canh -- Tab+s la Win+Shift+S, tuc chinh cai keo cat
; man hinh dat anh vao clipboard; Tab+v la buoc dua no di.
;
; Vi sao khong xai san cua herdr: `herdr --remote` CO bac anh clipboard tu may
; local sang phien remote (no chep anh thanh file tam ben server roi dan duong
; dan), nhung ban Windows khong co --remote -- upstream ghi thang "Native Windows
; `herdr --remote` is not part of the beta" -- va bo doc anh clipboard cung chua
; duoc noi day tren Windows. Cach dung duoc tu may nay la `ssh macmini` roi chay
; herdr ben do, va duong do khong cho anh di qua.
;
; Vi sao phai la phim tat, khong phai mot ham go ngay trong shell ssh do: do tren
; may nay, tien trinh do sshd sinh ra nam o Session 0 con explorer.exe o Session
; 1; hai session co clipboard RIENG. Ghi mot chuoi danh dau tu shell ssh roi doc
; lai chi thay clipboard cua chinh phien ssh, khong bao gio thay anh vua chup o
; desktop. Phim tat chay trong session desktop -- do la ca ly do file nay ton tai.
;
; Viec that nam o pwsh\ps1.d\herdr-clip.ps1 (doc clipboard, day qua ssh) va
; herdr-clip-recv ben macmini (luu file, go duong dan vao pane). O day chi co
; phim, toast va ma loi.

HerdrClipTarget := "macmini"

SendClipImage(*) {
    ps1 := EnvGet("USERPROFILE") "\Documents\PowerShell\ps1.d\herdr-clip.ps1"
    if !FileExist(ps1) {
        TrayTip "Khong thay herdr-clip.ps1 -- chay apply.ps1", "Herdr clip", 3
        return
    }

    ; -NoProfile cat khoang mot giay khoi moi lan bam phim; doi lai la phai tu
    ; dot-source file ham, vi khong co profile thi khong ai nap ps1.d ca.
    inner := ". '" ps1 "'; if (Send-ClipImage -Target " HerdrClipTarget ") { exit 0 } else { exit 1 }"

    ; "Hide" de khong nhay cua so console. RunWait chan thread nay khoang 2 giay
    ; (pwsh khoi dong + mot vong ssh) -- phim tat khac van bam duoc vi AHK cho
    ; thread moi ngat thread dang cho.
    try
        code := RunWait('pwsh -NoProfile -NoLogo -Command "' inner '"', , "Hide")
    catch as e {
        TrayTip "Khong chay duoc pwsh: " e.Message, "Herdr clip", 3
        return
    }

    if (code = 0)
        TrayTip "Da dan vao pane dang focus tren " HerdrClipTarget, "Herdr clip", 1
    else
        TrayTip "That bai -- xem %LOCALAPPDATA%\herdr-clip.log", "Herdr clip", 3
}
