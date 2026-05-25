; Polish prompt using aichat -r polish
; Tab+w — show/hide input (content preserved while hidden)
; Enter            — submit
; Esc              — cancel and clear

global _spellGui := "", _spellEdit := "", _spellVisible := false

tabkey := "^#+"

Hotkey(tabkey "w", (*) => SpellToggle())

SpellToggle() {
    global _spellGui, _spellEdit, _spellVisible

    if IsObject(_spellGui) {
        if _spellVisible {
            _spellGui.Hide()
            _spellVisible := false
        } else {
            _spellGui.Show("AutoSize")
            _spellEdit.Focus()
            SendMessage(0x00B1, -1, -1, _spellEdit)  ; EM_SETSEL: deselect, caret to end
            _spellVisible := true
        }
        return
    }

    _spellGui := Gui("+AlwaysOnTop -Caption +E0x08000000")
    _spellGui.BackColor := "21252b"
    _spellGui.MarginX := 12, _spellGui.MarginY := 12
    _spellGui.SetFont("s12 cabb2bf", "Segoe UI Variable Text")
    _spellEdit := _spellGui.AddEdit("w600 h120 Background21252b c61afef")
    _spellGui.Show("AutoSize")
    _spellEdit.Focus()
    _spellVisible := true

    HotIfWinActive("ahk_id " _spellGui.Hwnd)
    Hotkey("Enter",  (*) => SpellSubmit())
    Hotkey("Escape", (*) => SpellCancel())
    HotIf()
}

SpellSubmit() {
    global _spellGui, _spellEdit, _spellVisible
    typed := Trim(_spellEdit.Value)
    _spellGui.Destroy()
    _spellGui := "", _spellVisible := false

    if (typed = "")
        return

    tempIn  := A_Temp "\spelling_in.txt"
    tempOut := A_Temp "\spelling_out.txt"
    tempErr := A_Temp "\spelling_err.txt"
    tempPs  := A_Temp "\spelling.ps1"
    for f in [tempIn, tempOut, tempErr, tempPs]
        try FileDelete(f)

    FileAppend(typed, tempIn, "UTF-8")

    ; Build PS1 — add scoop shims path in case admin PATH is missing aichat
    psScript := '$env:PATH += ";$env:USERPROFILE\scoop\shims"' "`n"
    psScript .= '$text   = [IO.File]::ReadAllText("' tempIn '", [Text.Encoding]::UTF8)' "`n"
    psScript .= 'try {' "`n"
    psScript .= '    $out = ($text | & aichat -r polish) 2>&1' "`n"
    psScript .= '    [IO.File]::WriteAllText("' tempOut '", ($out -join "`n"), [Text.Encoding]::UTF8)' "`n"
    psScript .= '} catch {' "`n"
    psScript .= '    [IO.File]::WriteAllText("' tempErr '", $_.ToString(), [Text.Encoding]::UTF8)' "`n"
    psScript .= '}' "`n"
    FileAppend(psScript, tempPs, "UTF-8")

    ToolTip("Processing...")
    RunWait('powershell -NoProfile -ExecutionPolicy Bypass -File "' tempPs '"', , "Hide")
    ToolTip()

    if FileExist(tempErr) and (errMsg := Trim(FileRead(tempErr, "UTF-8"))) and errMsg != "" {
        MsgBox("PowerShell error:`n" errMsg, "Error", "Icon!")
        return
    }

    if !FileExist(tempOut) or !(fixed := Trim(FileRead(tempOut, "UTF-8"))) {
        MsgBox("No output received. Check file:`n" tempPs, "Error", "Icon!")
        return
    }

    A_Clipboard := fixed
    ShowResult(fixed)
}

SpellCancel() {
    global _spellGui, _spellVisible
    _spellGui.Destroy()
    _spellGui := "", _spellVisible := false
}
