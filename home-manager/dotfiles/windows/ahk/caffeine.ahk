#Requires AutoHotkey v2.0

; --- === Caffeine ===
;
; Keeps the MACHINE awake, with a dot top-right while it is on. Bound in
; tab-key.ahk.
;
; The macOS counterpart keeps the DISPLAY awake; this deliberately does not, and
; that difference is why the file exists. On a14 `powercfg /a` offers exactly one
; sleep state -- S0 Low Power Idle *Network Disconnected* -- so sleeping drops
; Tailscale and SSH. What has to stay up is the machine, not the screen.
;
; It is not redundant with power-manager.ahk: turning the screen off there lets
; Windows drift into S0 seconds later, and this request is what blocks that.
;
; Do NOT combine with look's Keep Awake, which also sets ES_DISPLAY_REQUIRED and
; would leave the screen lit all night -- exactly what is avoided here.
;
; Verify with `powercfg /requests`, not the dot: SYSTEM must list AutoHotkey64,
; DISPLAY must be None.

; A plain flag is enough here, unlike Caffeine.spoon, which must ask the system:
; the request is held by THIS process, so a reload or a crash drops it and resets
; the flag together. They cannot drift apart.
CaffeineOn := false
CaffeineDot := ""

ToggleCaffeine(*) {
    global CaffeineOn
    CaffeineSet(!CaffeineOn)
}

CaffeineSet(on) {
    global CaffeineOn, CaffeineDot

    ; ES_CONTINUOUS holds the request until cleared instead of nudging the idle
    ; timer once. ES_DISPLAY_REQUIRED is deliberately absent -- see the header.
    ; Returns 0 on failure; anything else is the previous state, not an error.
    flags := on ? 0x80000001 : 0x80000000
    if (DllCall("kernel32\SetThreadExecutionState", "UInt", flags, "UInt") = 0) {
        TrayTip "SetThreadExecutionState that bai", "Caffeine", 3
        return
    }

    CaffeineOn := on
    if (on)
        CaffeineShowDot()
    else if (CaffeineDot != "")
        CaffeineDot.Hide()
}

CaffeineShowDot() {
    global CaffeineDot

    ; A plain dot, no glyph. Copying Caffeine.spoon's design (a rounded box with
    ; an emoji) rendered as a black outlined circle spilling out of the box:
    ; Gui.AddText draws through GDI, which cannot read an emoji's COLR/CBDT colour
    ; tables and falls back to the monochrome glyph. A real colour emoji would
    ; need an embedded image and AddPic.
    if (CaffeineDot = "") {
        ; NOACTIVATE so it never steals focus, TRANSPARENT so clicks pass through.
        ;
        ; -DPIScale is REQUIRED: Gui scales by DPI while MonitorGetWorkArea and
        ; WinSetRegion both work in PHYSICAL pixels, so mixing them multiplies the
        ; coordinates twice and the region clips wrong -- that is what cut a corner
        ; off the dot on a 150% display.
        CaffeineDot := Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000 +E0x20")
        ; Deliberately outside lib/ui.ahk's One Dark palette: the matching yellow
        ; vanished against this desktop's pale background.
        CaffeineDot.BackColor := "ff8c1a"
        CaffeineDot.MarginX := 0, CaffeineDot.MarginY := 0
    }

    size := Round(16 * A_ScreenDPI / 96)
    gap := Round(8 * A_ScreenDPI / 96)

    ; Recomputed on every show, not once at load: an older version placed the dot
    ; by the monitor as it was at startup, so plugging a display moved it off screen.
    MonitorGetWorkArea(MonitorGetPrimary(), &left, &top, &right, &bottom)
    x := right - size - gap
    y := top + gap

    CaffeineDot.Show("NoActivate x" x " y" y " w" size " h" size)

    ; Clip against the ACTUAL size, not the numbers just passed in: any scaling
    ; layer between makes them disagree, and the symptom is a clipped corner.
    WinGetClientPos(, , &cw, &ch, CaffeineDot.Hwnd)
    WinSetRegion("0-0 w" cw " h" ch " E", CaffeineDot.Hwnd)
    WinSetTransparent(210, CaffeineDot.Hwnd)
}
