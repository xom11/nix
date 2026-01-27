
; Maximize / Half left / Half right window
Snap(winTitle, state) {
    if !hWnd := WinExist(winTitle)
        return

    WinRestore(hWnd)

    ; 1. Get the visible frame offset using DWM
    RECT := Buffer(16)
    DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", hWnd, "UInt", 9, "Ptr", RECT, "UInt", 16)

    WinGetPos(&X, &Y, , , hWnd)
    offset := NumGet(RECT, 0, "Int") - X

    ; 2. Get Work Area
    MonitorGetWorkArea(1, &L, &T, &R, &B)
    W := R - L
    H := B - T

    ; 3. Snap Logic
    if (state = "Max") {
        WinMaximize(hWnd)
    }
    else if (state = "Left") {
        ; Adjust position and width to compensate for invisible borders
        WinMove(L - offset, T, (W / 2) + (2 * offset), H + offset, hWnd)
    }
    else if (state = "Right") {
        ; Adjust X to start exactly at mid-screen minus offset
        WinMove(L + (W / 2) - offset, T, (W / 2) + (2 * offset), H + offset, hWnd)
    }
}

^#!,:: Snap("A", "Left")
^#!.:: Snap("A", "Right")
^#!/:: Snap("A", "Max")
#q::Send "!{F4}"

