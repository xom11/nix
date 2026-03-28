if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "=== Setting up Startup Services ===" -ForegroundColor Cyan
Write-Host ""

# ============================================
# AutoHotkey Task
# ============================================
Write-Host "[1/2] Configuring AutoHotkey..." -ForegroundColor Yellow

$TaskName = "AHKrunning"
$AhkExe   = "$env:USERPROFILE\scoop\shims\autohotkey.exe"
$AhkFile  = "$env:USERPROFILE\.nix\windows\ahk\main.ahk"

$Action = New-ScheduledTaskAction -Execute $AhkExe -Argument "`"$AhkFile`""
$Trigger = New-ScheduledTaskTrigger -AtLogon
$Principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Highest
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings -Force | Out-Null
Write-Host "✅ AutoHotkey task created" -ForegroundColor Green

# ============================================
# Syncthing Task
# ============================================
Write-Host "[2/2] Configuring Syncthing..." -ForegroundColor Yellow

$TaskName = "Syncthing"
$SyncthingExe = "$env:USERPROFILE\scoop\shims\syncthing.exe"

$Action = New-ScheduledTaskAction -Execute $SyncthingExe -Argument "--no-browser --no-console"
$Trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0 -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)
$Principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited

Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Principal $Principal -Description "Run Syncthing continuously in background" -Force | Out-Null
Write-Host "✅ Syncthing task created" -ForegroundColor Green

# ============================================
# Summary
# ============================================
Write-Host ""
Write-Host "=== All startup services configured! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Services will auto-start at logon:" -ForegroundColor Cyan
Write-Host "  • AutoHotkey (Run as Admin)" -ForegroundColor White
Write-Host "  • Syncthing (Web UI: http://localhost:8384)" -ForegroundColor White
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")