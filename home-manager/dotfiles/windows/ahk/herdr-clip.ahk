#Requires AutoHotkey v2.0

; --- === Herdr clip ===
;
; Chup man hinh o day, bam Tab+v, duong dan anh hien ra trong pane dang focus cua
; phien herdr tren may ban DANG ssh vao. Noi phim o tab-key.ahk (Tab+v), doi phim
; thi sua ben do. Di lien voi Tab+s ngay ben canh -- Tab+s la Win+Shift+S, tuc
; chinh cai keo cat man hinh dat anh vao clipboard; Tab+v la buoc dua no di.
;
; Vi sao khong xai san cua herdr: `herdr --remote` CO bac anh clipboard tu may
; local sang phien remote, va no co that tren macOS lan Linux (rog dang chay
; `herdr --remote macmini`). Nhung ban Windows khong co --remote -- upstream ghi
; thang "Native Windows `herdr --remote` is not part of the beta" -- va bo doc anh
; clipboard cung chua duoc noi day tren Windows. Cach dung duoc tu may nay la
; `ssh <host>` roi chay herdr ben do, va duong do khong cho anh di qua.
;
; Vi sao phai la phim tat, khong the la mot ham go trong chinh shell ssh do: do
; tren a14, tien trinh do sshd sinh ra nam o Session 0 con explorer.exe o Session
; 1; hai session co clipboard RIENG. Ghi mot chuoi danh dau tu shell ssh roi doc
; lai chi thay clipboard cua chinh phien ssh, khong bao gio thay anh vua chup o
; desktop. Phim tat chay trong session desktop -- do la ca ly do file nay ton tai.
;
; DICH KHONG CON LA HANG SO. Truoc day file nay ghi cung "macmini", nen ssh vao
; may khac roi bam Tab+v la anh bay ve macmini va roi vao pane cua mot phien
; khong ai dang nhin -- ma toast van bao thanh cong, vi no in lai chinh bien dau
; vao. Gio dich duoc doc tu argv cua cac tien trinh ssh.exe dang song (xem
; Resolve-HerdrTarget ben herdr-clip.ps1), va toast chi in nhung gi DAU KIA
; tra ve. Mot dich thi gui thang; nhieu dich thi hien menu; khong co dich nao thi
; TU CHOI, giu anh lai, khong doan.

SendClipImage(*) {
    RunHerdrClip()
}

RunHerdrClip(target := "", fromSaved := "") {
    ps1 := EnvGet("USERPROFILE") . "\Documents\PowerShell\ps1.d\herdr-clip.ps1"
    if !FileExist(ps1) {
        TrayTip "Khong thay herdr-clip.ps1 -- chay apply.ps1", "Herdr clip", 3
        return
    }

    ; -NoProfile cat khoang mot giay khoi moi lan bam phim; doi lai la phai tu
    ; dot-source file ham, vi khong co profile thi khong ai nap ps1.d ca.
    inner := ". '" . ps1 . "'; Invoke-HerdrClipHotkey"
    if (target != "")
        inner .= " -Target '" . target . "'"
    if (fromSaved != "")
        inner .= " -FromSaved '" . fromSaved . "'"

    ; "Hide" de khong nhay cua so console. RunWait chan thread nay khoang 2 giay
    ; (pwsh khoi dong + mot vong ssh, da co ConnectTimeout=5 chan truong hop may
    ; ngu) -- phim tat khac van bam duoc vi AHK cho thread moi ngat thread dang cho.
    try
        code := RunWait('pwsh -NoProfile -NoLogo -Command "' . inner . '"', , "Hide")
    catch as e {
        TrayTip "Khong chay duoc pwsh: " . e.Message, "Herdr clip", 3
        return
    }

    last := ReadClipResult()

    ; 0 ok / 1 clipboard rong / 2 khong co phien ssh / 3 nhieu phien / con lai: hong
    switch code {
        case 0:
            ; In THU DAU KIA TRA VE, khong in lai bien dau vao -- day la ca ly do
            ; dong dinh danh cua herdr-clip-recv ton tai.
            where := (last.Has("title") && last["title"] != "") ? last["title"] : last.Get("pane", "?")
            who := last.Get("agent", "")
            note := (who != "") ? ("  [" . who . "]") : ""
            TrayTip "-> " . where . note, "Herdr clip: " . last.Get("target", "?"), 1
        case 1:
            TrayTip "Clipboard khong co anh", "Herdr clip", 2
        case 2:
            TrayTip "Khong co phien ssh nao dang mo`nAnh giu o " . last.Get("saved", "?"), "Herdr clip", 3
        case 3:
            AskHerdrTarget(last)
        default:
            TrayTip "That bai -- xem %LOCALAPPDATA%\herdr-clip.log`nAnh giu o " . last.Get("saved", "?"), "Herdr clip", 3
    }
}

; Nhieu phien ssh cung mo thi khong doan: hien menu ngay tai con tro, va CHI liet
; ke nhung host dang that su co ket noi. Anh da duoc luu truoc khi menu hien ra,
; nen lan gui thu hai doc lai tu file -- clipboard co the da doi trong luc chon.
AskHerdrTarget(last) {
    cands := StrSplit(last.Get("candidates", ""), ",")
    saved := last.Get("saved", "")
    if (cands.Length = 0) {
        TrayTip "Nhieu phien ssh nhung khong doc duoc danh sach", "Herdr clip", 3
        return
    }

    chosen := ""
    m := Menu()
    for host in cands {
        if (host != "")
            m.Add(host, (name, *) => chosen := name)
    }
    m.Show()
    m.Delete()

    if (chosen != "")
        RunHerdrClip(chosen, saved)
    else
        TrayTip "Khong chon dich -- anh giu o " . saved, "Herdr clip", 2
}

; herdr-clip.ps1 ghi ket qua ra day thay vi stdout: RunWait chi tra ve mot so
; nguyen, ma so nguyen thi khong noi duoc anh roi vao pane nao.
ReadClipResult() {
    out := Map()
    path := EnvGet("LOCALAPPDATA") . "\herdr-clip.last"
    if !FileExist(path)
        return out
    try
        text := FileRead(path, "UTF-8")
    catch
        return out
    for line in StrSplit(text, "`n", "`r") {
        pos := InStr(line, "=")
        if (pos > 1)
            out[SubStr(line, 1, pos - 1)] := SubStr(line, pos + 1)
    }
    return out
}
