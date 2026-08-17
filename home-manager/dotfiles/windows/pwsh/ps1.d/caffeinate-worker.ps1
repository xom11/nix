# Giu may thuc chung nao tien trinh nay con song, va nha ra ngay khi no chet.
# Start-Caffeinate / Stop-Caffeinate trong functions.ps1 lo viec bat tat -- khong co
# ly do gi chay file nay bang tay.
#
# CA FILE thuan ASCII, ke ca chu thich, va do la co y. Moi file khac o day duoc pwsh 7
# dot-source, noi file khong BOM duoc doc la UTF-8; file nay la ngoai le vi no duoc goi
# bang -File, nen neu co ngay nao roi ve powershell.exe 5.1 thi no doc theo ANSI -- mot
# ky tu co dau se bien thanh nhay cong va cat dut chuoi. Xem CLAUDE.md.
param([int]$Minutes = 0)   # 0 = toi khi bi dung

Add-Type -Namespace Caffeinate -Name Power -MemberDefinition @'
[DllImport("kernel32.dll", SetLastError = true)]
public static extern uint SetThreadExecutionState(uint esFlags);
'@

# PHAI ep [uint32], va day la cho da truot mot lan. PowerShell doc hang hex lap day
# 32 bit thanh Int32 CO DAU, nen `0x80000001` la -2147483647 chu khong phai 2147483649.
# Truyen thang vao tham so uint thi loi goi nem loi chuyen kieu, ma
# $ErrorActionPreference mac dinh la Continue nen script chay tiep binh thuong: tien
# trinh song, khong co power request nao duoc dat, va khong mot dong nao bao.
$ES_CONTINUOUS      = [uint32]2147483648   # 0x80000000
$ES_SYSTEM_REQUIRED = [uint32]1            # 0x00000001

# ES_DISPLAY_REQUIRED (0x2) bi BO RA CO CHU Y, va do la toan bo diem cua file nay: man
# hinh van theo timeout rieng cua no trong khi may dung thuc. Them co do vao la duoc mot
# cai laptop khong bao gio tat man.
#
# Power request chi chan duong vao Modern Standby do NHAN ROI. No khong chan lenh ngu do
# nguoi dung ra -- dong nap khi dang cam sac thi may nay van ngu, va do la lua chon.
if ([Caffeinate.Power]::SetThreadExecutionState($ES_CONTINUOUS -bor $ES_SYSTEM_REQUIRED) -eq 0) {
    # Ham chi tra 0 khi that bai; nguoc lai no tra trang thai truoc do, khong phai loi.
    exit 1
}

if ($Minutes -gt 0) {
    Start-Sleep -Seconds ($Minutes * 60)
} else {
    while ($true) { Start-Sleep -Seconds 3600 }
}
