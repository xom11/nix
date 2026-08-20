#Requires AutoHotkey v2.0

; --- === Ferry ===
;
; Tab+v copies the clipboard image to whichever machine you are ssh'd into and
; TYPES its path at the cursor. Bound in tab-key.ahk, next to Tab+s (Win+Shift+S),
; which is what puts the screenshot on the clipboard in the first place.
;
; Exists because `herdr --remote` covers this on macOS and Linux but not on
; Windows, where the documented shape is plain `ssh <host>` -- and that lets no
; image through. Nothing here touches herdr, so it works into tmux, a bare shell
; or an editor too; see DeliverPath().
;
; It must be a hotkey, not a function in the ssh shell: sshd spawns into Session 0
; while explorer.exe is in Session 1, and the two have SEPARATE clipboards.
;
; The target is NOT a constant. It used to be hardcoded to "macmini", so pressing
; this from any other session sent the image there while still reporting success.
; It is now read from the argv of live ssh.exe processes in this session (see
; Resolve-FerryTarget). One match sends; several show a menu; none REFUSES rather
; than guessing, and keeps the image.

FerryImage(*) {
    RunFerry()
}

RunFerry(target := "", fromSaved := "") {
    ; Record the focused window BEFORE leaving, to compare on return.
    hwnd := WinExist("A")

    ps1 := EnvGet("USERPROFILE") . "\Documents\PowerShell\ps1.d\ferry.ps1"
    if !FileExist(ps1) {
        TrayTip "Khong thay ferry.ps1 -- chay apply.ps1", "Herdr clip", 3
        return
    }

    ; -NoProfile saves about a second per press, at the cost of dot-sourcing the
    ; function file by hand -- without a profile nothing loads ps1.d.
    inner := ". '" . ps1 . "'; Invoke-FerryHotkey"
    if (target != "")
        inner .= " -Target '" . target . "'"
    if (fromSaved != "")
        inner .= " -FromSaved '" . fromSaved . "'"

    ; RunWait blocks this thread for ~2 s (pwsh startup plus one ssh round trip,
    ; bounded by ConnectTimeout=5). Other hotkeys still work: AHK lets a new thread
    ; interrupt a waiting one.
    try
        code := RunWait('pwsh -NoProfile -NoLogo -Command "' . inner . '"', , "Hide")
    catch as e {
        TrayTip "Khong chay duoc pwsh: " . e.Message, "Herdr clip", 3
        return
    }

    last := ReadFerryResult()

    ; 0 ok / 1 no image / 2 no ssh session / 3 several / anything else: failed
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

; Typing happens HERE, not via `herdr pane send-text`, which raises a question
; with no correct answer: the server's one `focused` pane belongs to whichever
; client focused last, so with two herdr sessions it targets a pane nobody is
; looking at. herdr's own docs say not to rely on another client's focused pane.
;
; Typing locally makes the question disappear -- the focused window IS the ssh
; terminal -- and it works outside herdr as well.
;
; The cost is typing blind: the round trip takes a second or two, long enough to
; Alt-Tab away. So compare the hwnd from before with the one now: same window
; types, a different one falls back to the clipboard and says so.
DeliverPath(path, target, hwnd) {
    if (path = "") {
        ShowFerryPopup("Gui xong nhung khong nhan duoc duong dan", "xem ferry.log", "e5c07b")
        return
    }

    if (hwnd && WinActive("ahk_id " . hwnd)) {
        ; Trailing space, no Enter: the image is only the preamble.
        SendText(path . " ")
        SplitPath(path, &name)
        ShowFerryPopup("-> " . target, name, "98c379")
        return
    }

    A_Clipboard := path
    ShowFerryPopup("Cua so da doi -- khong go mu", "duong dan da vao clipboard: " . path, "61afef")
}

; Not TrayTip: it hangs off the tray icon and Windows may simply not show it --
; measured, a fully successful send that the user never saw, because the icon was
; in overflow or a fullscreen app had triggered do-not-disturb.
;
; A deliberate copy of ShowPopup from lib/ui.ahk, differing in one way: it closes
; on a timer rather than waiting for a key. ShowPopup's InputHook SWALLOWS one
; keypress, which is fine for checking the time but not here, where the user is
; about to type their question.
ShowFerryPopup(mainText, subText, accentColor) {
    ui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000")
    ui.BackColor := "21252b"
    ui.MarginX := 20, ui.MarginY := 16

    ui.SetFont("s15 w700 c" . accentColor, "Segoe UI Variable Display")
    ui.AddText("w560", mainText)

    ui.SetFont("s11 w400 cabb2bf", "Segoe UI Variable Text")
    ui.AddText("w560", subText)

    ; NoActivate: never steal focus mid-typing.
    ui.Show("NoActivate")
    SetTimer(() => TryDestroy(ui), -2600)
}

TryDestroy(ui) {
    try ui.Destroy()
}

; Several sessions: show a menu of hosts actually connected. The image was saved
; before the menu appeared, so the second pass re-reads the file -- the clipboard
; may have moved on while choosing.
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

    ; The send lives INSIDE the callback, not after m.Show(): Show returns before
    ; the callback runs on another thread, so reading a "chosen yet?" variable
    ; after it bets on an order nothing guarantees. This closure captures `saved`
    ; from this call, so no shared variable is needed.
    ;
    ; Same reason there is no "nothing chosen" toast: telling that apart from
    ; "just chose" needs that same order.
    ChooseTarget(name, *) {
        RunFerry(name, saved)
    }
}

; ferry.ps1 writes here rather than to stdout: RunWait returns only an integer,
; which cannot carry a path.
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
