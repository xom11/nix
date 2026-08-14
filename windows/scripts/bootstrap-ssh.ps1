# Bat SSH tren mot may Windows vua cai xong, de con lai lam moi thu khac tu xa.
#
# Chay bang mot dong, khong phai go tay ca khoi lenh:
#
#   irm https://raw.githubusercontent.com/xom11/nix/main/windows/scripts/bootstrap-ssh.ps1 | iex
#
# CO Y tach khoi windows/modules/services/sshd/module.ps1 thay vi goi lai no.
# Module do can $Ctx va cac helper Write-OK/Write-Skip cua apply.ps1, ma
# apply.ps1 thi co danh sach module HARDCODE -- chay no tren may trang se keo
# theo dotpkg, pwsh, npm va toan bo config AI. Day chi la buoc mo cua.
#
# Sau khi SSH thong, chay apply.ps1 day du qua SSH voi -NoElevate; luc do module
# sshd that se tiep quan va lam not phan nay script bo qua:
#   - DefaultShell tro sang pwsh 7 (chua cai o day, nen bo qua)
#   - ssh-agent chuyen sang Disabled
#
# Ten rule firewall giu DUNG bang module that ('OpenSSH-Server-In-TCP') de lan
# apply sau no thay la da xong chu khong tao them mot rule trung lap.

$ErrorActionPreference = 'Stop'

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
        ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error 'Phai chay PowerShell voi quyen Administrator.'
    exit 1
}

# Kiem binary truoc khi hoi DISM: Get-WindowsCapability -Online di qua DISM va ton
# vai giay, trong khi thu no giao ra chi la hai file exe nay.
$opensshBin = Join-Path $env:SystemRoot 'System32\OpenSSH'
foreach ($cap in @(
        @{ Name = 'OpenSSH.Client~~~~0.0.1.0'; Exe = 'ssh.exe' }
        @{ Name = 'OpenSSH.Server~~~~0.0.1.0'; Exe = 'sshd.exe' }
    )) {
    if (Test-Path (Join-Path $opensshBin $cap.Exe)) {
        Write-Host "  co san : $($cap.Name)"
        continue
    }
    Write-Host "  dang cai: $($cap.Name) (30-60 giay)"
    Add-WindowsCapability -Online -Name $cap.Name | Out-Null
    Write-Host "  xong    : $($cap.Name)"
}

Set-Service -Name sshd -StartupType Automatic
if ((Get-Service sshd).Status -ne 'Running') { Start-Service sshd }
Write-Host '  sshd    : Automatic, Running'

$ruleName = 'OpenSSH-Server-In-TCP'
if (-not (Get-NetFirewallRule -Name $ruleName -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -Name $ruleName -DisplayName 'OpenSSH Server (sshd)' `
        -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 | Out-Null
    Write-Host '  firewall: da mo TCP 22'
} else {
    Write-Host '  firewall: TCP 22 da mo tu truoc'
}

Write-Host ''
Write-Host '===== DAN KHOI NAY CHO CLAUDE ====='
Write-Host "user   : $env:USERNAME"
Write-Host "host   : $env:COMPUTERNAME"
Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' } |
    ForEach-Object { Write-Host "ip     : $($_.IPAddress)  ($($_.InterfaceAlias))" }
Write-Host "sshd   : $((Get-Service sshd).Status)"
Write-Host '==================================='
