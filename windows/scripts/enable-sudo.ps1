# Enable built-in Windows features that make daily shell life nicer.
# Run once with admin: powershell -ExecutionPolicy Bypass -File enable-sudo.ps1

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',"`"$PSCommandPath`"")
    exit
}

Write-Host "==> Enabling Windows sudo (inline mode)" -ForegroundColor Cyan
$sudoKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Sudo'
if (-not (Test-Path $sudoKey)) { New-Item -Path $sudoKey -Force | Out-Null }
Set-ItemProperty -Path $sudoKey -Name 'Enabled' -Type DWord -Value 3   # 3 = inline / normal
Write-Host "  sudo enabled. Use: sudo <command>" -ForegroundColor Green
Write-Host "  Modes: 0=disabled, 1=new window, 2=disable input, 3=inline"

Write-Host ""
Write-Host "==> Enabling Developer Mode (allows symlinks without admin)" -ForegroundColor Cyan
$devKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'
if (-not (Test-Path $devKey)) { New-Item -Path $devKey -Force | Out-Null }
Set-ItemProperty -Path $devKey -Name 'AllowDevelopmentWithoutDevLicense' -Type DWord -Value 1
Write-Host "  Developer Mode enabled." -ForegroundColor Green

Write-Host ""
Write-Host "Done. Sign out and back in for sudo PATH to fully activate." -ForegroundColor Yellow
