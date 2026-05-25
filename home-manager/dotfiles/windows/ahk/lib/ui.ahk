#Requires AutoHotkey v2.0

ShowPopup(mainText, subText, accentColor) {
    ui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000")
    ui.BackColor := "21252b"
    ui.MarginX := 20, ui.MarginY := 25

    ui.SetFont("s60 w700 c" accentColor, "Segoe UI Variable Display")
    ui.AddText("Center w450", mainText)

    ui.SetFont("s15 w400 cabb2bf", "Segoe UI Variable Text")
    ui.AddText("Center w450", subText)

    ui.Show("NoActivate")
    ih := InputHook("L1 T3")
    ih.Start(), ih.Wait()
    ui.Destroy()
}

; Shows rewritten result — any key or click to dismiss
ShowResult(text) {
    g := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000")
    g.BackColor := "21252b"
    g.MarginX := 20, g.MarginY := 20

    g.SetFont("s11 w600 c98c379", "Segoe UI Variable Text")
    g.AddText("w560", "Copied to clipboard")

    g.SetFont("s13 w400 cabb2bf", "Segoe UI Variable Text")
    g.AddText("w560 y+8", text)

    g.SetFont("s10 w400 c4b5263", "Segoe UI Variable Text")
    g.AddText("w560 y+14", "press any key to dismiss")

    g.Show("AutoSize NoActivate")
    ih := InputHook("L1 T10")
    ih.Start(), ih.Wait()
    g.Destroy()
}

; Returns typed string, or "" if cancelled (Esc / empty)
ShowInput(placeholder := "") {
    typed := "", done := false
    g := Gui("+AlwaysOnTop -Caption +E0x08000000")
    g.BackColor := "21252b"
    g.MarginX := 12, g.MarginY := 12
    g.SetFont("s12 cabb2bf", "Segoe UI Variable Text")
    edit := g.AddEdit("w600 h120 Background21252b c61afef")
    if (placeholder != "")
        edit.Value := placeholder
    g.Show("AutoSize")
    edit.Focus()

    HotIfWinActive("ahk_id " g.Hwnd)
    Hotkey("Enter",  (*) => (typed := edit.Value, done := true,  g.Destroy()))
    Hotkey("Escape", (*) => g.Destroy())
    HotIf()

    WinWaitClose("ahk_id " g.Hwnd)
    return (done and Trim(typed) != "") ? typed : ""
}
