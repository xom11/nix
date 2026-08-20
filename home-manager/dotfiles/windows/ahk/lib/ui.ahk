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

; ShowResult and ShowInput used to live here for a rewrite-and-copy feature that
; was dropped; nothing in the repo called them any more. Recover from git if needed.
