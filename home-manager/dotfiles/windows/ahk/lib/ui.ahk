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

; ShowResult va ShowInput tung o day, phuc vu mot tinh nang "viet lai van ban roi
; copy" da bo tu lau; den 08/2026 thi khong con cho nao trong repo goi toi nua nen
; da xoa. Can lai thi lay tu git.
