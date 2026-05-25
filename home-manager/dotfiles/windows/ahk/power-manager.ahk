#Requires AutoHotkey v2.0

; Lock Workstation
#!l::DllCall("LockWorkStation")

; Sleep
#!s::DllCall("PowrProf\SetSuspendState", "Int", 0, "Int", 0, "Int", 0)

; Lock out 
+#!L:: {
    if MsgBox("Sign out?", "Logoff", 4) = "Yes"
        Shutdown 0
}

; Restart
+#!r:: {
    if MsgBox("Restart computer?", "Reboot", 4) = "Yes"
        Shutdown 2
}

; Shutdown
+#!s:: {
    if MsgBox("Shutdown computer?", "Power Off", 4) = "Yes"
        Shutdown 1
}