if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -File `"$PSCommandPath`"" -Verb RunAs
    exit
}
# --- Configuration ---
$TaskName = "AHKrunning"
$AhkExe   = "$env:USERPROFILE\scoop\shims\autohotkey.exe"
$AhkFile  = "$env:USERPROFILE\Documents\nix\windows\ahk\main.ahk"

# 1. Define the action: Run AHK with the script path as an argument
$Action = New-ScheduledTaskAction -Execute $AhkExe -Argument "`"$AhkFile`""

# 2. Define the trigger: Run at user logon
$Trigger = New-ScheduledTaskTrigger -AtLogon

# 3. Define privileges: Set to 'Highest' (Run as Administrator)
$Principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Highest

# 4. Define settings: Ensure it runs on laptops even when not plugged in
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

# 5. Register the task (Force overwrite if exists)
Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings -Force

Write-Host "Success: Task '$TaskName' created. AHK will now start as Admin at logon." -ForegroundColor Green