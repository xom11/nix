; Fix spelling/grammar using Claude CLI
; Hotkey: Ctrl+Shift+Space


^+Space:: {
    typed := ShowInput()
    if (typed = "")
        return

    tempIn  := A_Temp "\spelling_in.txt"
    tempOut := A_Temp "\spelling_out.txt"
    tempErr := A_Temp "\spelling_err.txt"
    tempPs  := A_Temp "\spelling.ps1"
    for f in [tempIn, tempOut, tempErr, tempPs]
        try FileDelete(f)

    FileAppend(typed, tempIn, "UTF-8")

    ; Build PS1 — add user npm path in case admin PATH is missing claude
    psScript := '$env:PATH += ";$env:APPDATA\npm;$env:LOCALAPPDATA\Programs\nodejs"' "`n"
    psScript .= '$env:CLAUDE_CODE_GIT_BASH_PATH = "C:\Users\kln\scoop\apps\git\current\bin\bash.exe"' "`n"
    psScript .= '$text   = [IO.File]::ReadAllText("' tempIn '", [Text.Encoding]::UTF8)' "`n"
    psScript .= 'try {' "`n"
    psScript .= '    $out = (& claude -p "/rw $text") 2>&1' "`n"
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
