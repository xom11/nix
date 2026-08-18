#Requires AutoHotkey v2.0

; --- === Ferry ===
;
; Chup man hinh o day, bam Tab+v: anh duoc chep sang may ban dang ssh vao, roi
; duong dan cua no duoc GO ra ngay tai cho con tro dang nhap nhay. Noi phim o
; tab-key.ahk (Tab+v), doi phim thi sua ben do. Di lien voi Tab+s ngay ben canh --
; Tab+s la Win+Shift+S, tuc chinh cai keo cat man hinh dat anh vao clipboard;
; Tab+v la buoc dua no di.
;
; Ten cu la herdr-clip, doi khi no khong con dinh gi toi herdr nua: go ra o day
; chu khong nho dau kia go ho, nen no chay trong BAT CU thu gi dang nhan phim --
; herdr, tmux, shell tran, editor. Dau kia cung khong cai gi ca. Ly do day du o
; DeliverPath().
;
; Cai thieu von la thieu ben herdr: `herdr --remote` CO bac anh clipboard tu may
; local sang phien remote, va no co that tren macOS lan Linux (rog dang chay
; `herdr --remote macmini`). Nhung ban Windows khong co --remote -- upstream ghi
; thang "Native Windows `herdr --remote` is not part of the beta" -- va bo doc anh
; clipboard cung chua duoc noi day tren Windows. Cach dung duoc tu may nay la
; `ssh <host>` roi chay gi tuy thich ben do, va duong do khong cho anh di qua.
;
; Vi sao phai la phim tat, khong the la mot ham go trong chinh shell ssh do: do
; tren a14, tien trinh do sshd sinh ra nam o Session 0 con explorer.exe o Session
; 1; hai session co clipboard RIENG. Ghi mot chuoi danh dau tu shell ssh roi doc
; lai chi thay clipboard cua chinh phien ssh, khong bao gio thay anh vua chup o
; desktop. Phim tat chay trong session desktop -- do la ca ly do file nay ton tai.
;
; DICH KHONG CON LA HANG SO. Truoc day file nay ghi cung "macmini", nen ssh vao
; may khac roi bam Tab+v la anh bay ve macmini, ma thong bao van noi thanh cong
; vi no in lai chinh bien dau vao. Gio dich duoc doc tu argv cua cac tien trinh
; ssh.exe dang song trong session desktop (xem Resolve-FerryTarget ben
; ferry.ps1). Mot dich thi gui thang; nhieu dich thi hien menu chi gom host
; dang that su mo; khong co dich nao thi TU CHOI, giu anh lai, khong doan.

FerryImage(*) {
    RunFerry()
}

RunFerry(target := "", fromSaved := "") {
    ; Ghi lai cua so dang focus TRUOC khi di, de con doi chieu luc ve. Xem
    ; DeliverPath() ben duoi.
    hwnd := WinExist("A")

    ps1 := EnvGet("USERPROFILE") . "\Documents\PowerShell\ps1.d\ferry.ps1"
    if !FileExist(ps1) {
        TrayTip "Khong thay ferry.ps1 -- chay apply.ps1", "Herdr clip", 3
        return
    }

    ; -NoProfile cat khoang mot giay khoi moi lan bam phim; doi lai la phai tu
    ; dot-source file ham, vi khong co profile thi khong ai nap ps1.d ca.
    inner := ". '" . ps1 . "'; Invoke-FerryHotkey"
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

    last := ReadFerryResult()

    ; 0 ok / 1 clipboard rong / 2 khong co phien ssh / 3 nhieu phien / con lai: hong
    switch code {
        case 0:
            DeliverPath(last.Get("path", ""), last.Get("target", "?"), hwnd)
        case 1:
            ShowFerryPopup("Clipboard khong co anh", "chup bang Tab+s roi bam lai", "e5c07b")
        case 2:
            ShowFerryPopup("Khong co phien ssh nao dang mo", "anh giu o " . last.Get("saved", "?"), "e06c75")
        case 3:
            AskFerryTarget(last)
        default:
            ShowFerryPopup("That bai", "xem ferry.log -- anh giu o " . last.Get("saved", "?"), "e06c75")
    }
}

; Khau giao: go duong dan vao cua so dang focus O DAY.
;
; Ban dau viec nay do dau kia lam -- `herdr pane send-text <pane>` -- va no keo
; theo cau hoi "pane nao", cau hoi khong co cau tra loi dung: pane `focused` duy
; nhat cua server thuoc ve client nao vua co focus, nen tren may chay hai phien
; herdr no tro vao pane nguoi dung khong he nhin. Chinh tai lieu skill cua herdr
; ghi "Do not rely on another client's focused pane."
;
; Go o day thi cau hoi bien mat: phim di vao cua so dang focus, ma cua so dang
; focus CHINH LA terminal ban dang ssh. Doi lai la no chay duoc ca ngoai herdr --
; tmux, shell tran, editor -- va dau kia khong con can herdr, jq hay mot server
; nao dang chay.
;
; Doi lai nua: go mu. Vong di ve mat mot hai giay, du de Alt-Tab sang Chrome, va
; luc do duong dan se duoc go vao Chrome. Nen so sanh hwnd luc bam voi hwnd luc
; ve: con dung cua so thi go, doi roi thi KHONG go gi ca, dat vao clipboard va
; noi ro. Khong bao gio go nham cho, va cung khong mat gi.
DeliverPath(path, target, hwnd) {
    if (path = "") {
        ShowFerryPopup("Gui xong nhung khong nhan duoc duong dan", "xem ferry.log", "e5c07b")
        return
    }

    if (hwnd && WinActive("ahk_id " . hwnd)) {
        ; Dau cach o cuoi, khong co Enter: anh chi la ve de, cau hoi sau no van la
        ; thu nguoi dung go tiep.
        SendText(path . " ")
        SplitPath(path, &name)
        ShowFerryPopup("-> " . target, name, "98c379")
        return
    }

    A_Clipboard := path
    ShowFerryPopup("Cua so da doi -- khong go mu", "duong dan da vao clipboard: " . path, "61afef")
}

; Vi sao khong dung TrayTip: no gan voi icon khay, va Windows co quyen khong hien.
; Do tren a14 -- mot lan gui THANH CONG hoan toan (ferry.last ghi status=ok,
; dung pane, dung title) ma nguoi dung khong thay gi ca. Icon bi day vao overflow,
; hoac Win11 tu bat do-not-disturb khi co app toan man hinh, la du de nuot no.
; Mot phan hoi khong bao gio den thi bang khong co phan hoi.
;
; Ban sao co chu y cua ShowPopup ben lib/ui.ahk, khac dung mot cho: tu tat bang
; SetTimer chu khong doi phim. ShowPopup dung InputHook("L1 T3"), tuc NUOT mot
; phim -- chap nhan duoc khi xem gio, nhung o day nguoi dung vua dan anh xong va
; se go cau hoi ngay sau do, mat mot ky tu dau la khong duoc.
ShowFerryPopup(mainText, subText, accentColor) {
    ui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000")
    ui.BackColor := "21252b"
    ui.MarginX := 20, ui.MarginY := 16

    ui.SetFont("s15 w700 c" . accentColor, "Segoe UI Variable Display")
    ui.AddText("w560", mainText)

    ui.SetFont("s11 w400 cabb2bf", "Segoe UI Variable Text")
    ui.AddText("w560", subText)

    ; NoActivate: dang go dở thi khong duoc cuop focus.
    ui.Show("NoActivate")
    SetTimer(() => TryDestroy(ui), -2600)
}

TryDestroy(ui) {
    try ui.Destroy()
}

; Nhieu phien ssh cung mo thi khong doan: hien menu ngay tai con tro, va CHI liet
; ke nhung host dang that su co ket noi. Anh da duoc luu truoc khi menu hien ra,
; nen lan gui thu hai doc lai tu file -- clipboard co the da doi trong luc chon.
AskFerryTarget(last) {
    cands := StrSplit(last.Get("candidates", ""), ",")
    saved := last.Get("saved", "")
    if (cands.Length = 0) {
        TrayTip "Nhieu phien ssh nhung khong doc duoc danh sach", "Herdr clip", 3
        return
    }

    m := Menu()
    for host in cands {
        if (host != "")
            m.Add(host, ChooseTarget)
    }
    m.Show()
    return

    ; Viec gui nam TRONG callback, khong phai o dong sau m.Show(). Menu tra dieu
    ; khien ve roi moi chay callback tren mot thread khac, nen doc mot bien
    ; "da chon chua" ngay sau Show() la cuoc vao thu tu khong ai bao dam -- rat de
    ; ra: bam chon xong ma khong co gi xay ra. Ham long nay bat duoc `saved` cua
    ; chinh lan goi nay, nen khong can bien chia se nao het.
    ;
    ; Vi cung ly do do, khong co toast "khong chon dich": phan biet "vua thoat
    ; menu" voi "vua chon xong" doi hoi dung thu tu do. Anh da nam tren dia va
    ; ferry.log da ghi 'several ssh sessions', the la du.
    ChooseTarget(name, *) {
        RunFerry(name, saved)
    }
}

; ferry.ps1 ghi ket qua ra day thay vi stdout: RunWait chi tra ve mot so
; nguyen, ma so nguyen thi khong noi duoc anh roi vao pane nao.
ReadFerryResult() {
    out := Map()
    path := EnvGet("LOCALAPPDATA") . "\ferry.last"
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
