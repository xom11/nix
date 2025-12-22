#Requires AutoHotkey v2.0

/**
 * WhichKey: Displays a popup menu and executes actions based on key input.
 * @param title  Menu header text
 * @param keyMap Map object containing {Key: {Desc, Action}}
 */
WhichKey(title, keyMap) {
    ; 1. GUI Setup: Dark mode, frameless, non-interactive (no focus)
    wkGui := Gui("AlwaysOnTop -Caption +ToolWindow +Owner +E0x08000000")
    wkGui.BackColor := "1e1e1e", wkGui.MarginX := 20, wkGui.MarginY := 20
    
    ; 2. Build UI Content
    wkGui.SetFont("s12 w700 c61afef", "Segoe UI") ; Purple header
    wkGui.AddText("Center w300", title)
    
    listStr := ""
    for k, v in keyMap
        listStr .= Format("[{}]  {}`n", k, v.Desc)
        
    wkGui.SetFont("s11 w400 cCCCCCC", "Consolas") ; Grey monospaced list
    wkGui.AddText("Left", listStr)
    wkGui.Show("AutoSize NoActivate")

    ; 3. Input Handling: Wait for 1 keypress or 3s timeout
    ih := InputHook("L1 T3")
    ih.Start(), ih.Wait()
    wkGui.Destroy()

    ; 4. Execution: Run action if key exists in map
    if (ih.Input != "" && keyMap.Has(ih.Input))
        keyMap[ih.Input].Action.Call()
}