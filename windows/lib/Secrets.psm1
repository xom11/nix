# Đọc file secret dùng chung với macOS/Linux. Nguồn là cú pháp shell
# (`export K="V"`) vì đó là thứ zsh source trực tiếp; ở đây `export` chỉ là
# tiền tố tuỳ chọn cần bỏ qua.
#
# Value được coi là chữ thuần: không nội suy `$`, backtick hay `$(...)`. Luật đó
# ghi ở CLAUDE.md. Sinh ra chuỗi nháy đơn của PowerShell nên kể cả khi luật bị
# vi phạm cũng không có gì được thực thi.

# KHÔNG có `-Force` ở đây. `-Force` chạy `Remove-Module` trước khi import lại,
# và khi lời gọi xuất phát từ *bên trong* một module thì bản import lại rơi vào
# session state riêng của module đó -- global binding bị xoá chứ không được
# thay. apply.ps1 import Logging.psm1 vào session toàn cục trước, nên chỉ cần
# `Import-Module Secrets.psm1` một lần là `Write-Section` biến mất khỏi vòng
# lặp module: `programs.agenix` in "OK" xong, vòng kế tiếp gọi Write-Section ở
# ngoài try trong cùng, ném CommandNotFoundException lên try ngoài và thoát 1 --
# 8 module còn lại (kể cả services.sshd, thứ giữ SSH vào máy) không bao giờ
# chạy. Không `-Force` thì import này là no-op khi Logging đã có sẵn, và vẫn nạp
# thật khi Secrets.psm1 được import độc lập (Update-Secrets, test).
Import-Module (Join-Path $PSScriptRoot 'Logging.psm1') -DisableNameChecking

function ConvertFrom-ShellEnv {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Text
    )

    $pairs = [ordered]@{}

    foreach ($line in ($Text -split "`r?`n")) {
        $trimmed = $line.Trim()
        if ($trimmed -eq '')            { continue }
        if ($trimmed.StartsWith('#'))   { continue }
        if ($trimmed -notmatch '^(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)=(.*)$') { continue }

        $name  = $Matches[1]
        $value = $Matches[2].Trim()

        # Chỉ bỏ đúng một cặp nháy bọc ngoài. Nháy bên trong là dữ liệu.
        if ($value.Length -ge 2) {
            $first = $value[0]
            $last  = $value[$value.Length - 1]
            if (($first -eq '"' -and $last -eq '"') -or ($first -eq "'" -and $last -eq "'")) {
                $value = $value.Substring(1, $value.Length - 2)
            }
        }

        $pairs[$name] = $value
    }

    return $pairs
}

# Siết ACL về đúng một principal, không kế thừa. Đọc `$LASTEXITCODE` rồi reset
# ngay: nó là biến toàn cục của cả tiến trình PowerShell chứ không cục bộ hàm,
# nên một icacls hỏng (LOCALAPPDATA trỏ sang share, volume không mang ACL,
# identity không phân giải được) sẽ để lại giá trị khác 0 sống sót qua phần còn
# lại của tiến trình -- làm bẩn segment exit-status của prompt trong shell
# tương tác, và làm đỏ job CI về sau vì runner Actions (`shell: powershell`) tự
# `exit $LASTEXITCODE` dù Pester báo 0 test fail. Cùng bẫy mà Update-PwshSecrets
# đã phải xử lý; hai nửa của cùng một module không được nghĩ khác nhau về nó.
function Set-RestrictiveAcl {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Principal
    )

    # 'Continue' trong phạm vi hàm này: bất kỳ dòng stderr nào của native command
    # cũng thành ErrorRecord trong Windows PowerShell 5.1, và dưới
    # `$ErrorActionPreference = 'Stop'` (apply.ps1 đặt) một dòng cảnh báo vô hại
    # của icacls đủ để ném terminating error, cướp mất chính nhánh kiểm mã thoát
    # ngay bên dưới. Mã thoát mới là thứ quyết định ở đây.
    $ErrorActionPreference = 'Continue'
    & icacls $Path /inheritance:r /grant:r "${Principal}:(R,W)" | Out-Null
    $rc = $LASTEXITCODE
    $global:LASTEXITCODE = 0
    if ($rc -ne 0) { throw "icacls failed on $Path (exit code $rc)" }
}

# Ghi qua temp rồi thay thế đích, giống hệt `agenix-reload` trên Unix và vì
# cùng lý do: một lần ghi hỏng không được để lại file cụt, và không được xoá
# mất bản cũ.
#
# ACL được đặt HAI lần, và cả hai đều cần thiết. Lần trên `$tmp` đóng khoảng
# thời gian file mới tồn tại với quyền kế thừa trước khi được cài, và là lần
# duy nhất có tác dụng ở đường ghi đầu tiên (File.Move). Nhưng ở đường ghi đè,
# `ReplaceFileW` của Win32 mang DACL của *file bị thay thế* sang file thay thế
# -- ACL đặt trên `$tmp` bị vứt đi. Nên nếu file đích từng được tạo với quyền
# kế thừa (khôi phục từ backup, copy từ máy khác, tạo tay lúc debug), mọi lần
# apply sau đó sẽ giữ nguyên quyền rộng đó mà vẫn báo "OK". Vì thế phải đặt lại
# ACL trên chính file đích sau khi cài xong, đường nào cũng vậy.
#
# KHÔNG dùng `Move-Item -Force`: khi đích đã tồn tại, PowerShell xoá đích rồi
# mới move lại (không atomic), và nếu lần move lại đó thất bại -- AV hay
# search indexer giữ khoá tạm thời, chuyện thường trên Windows -- lỗi chỉ là
# non-terminating (WriteError). Hệ quả: file cũ đã mất, file mới chưa tới,
# không gì throw, và hàm vẫn trả về như đã ghi xong. Đó chính xác là điều
# thiết kế temp+move tồn tại để ngăn.
#
# Dùng [System.IO.File]::Replace khi đích đã có: atomic thật (ReplaceFile
# của Win32), sẵn trên .NET Framework 4.x -- khác overload 3 tham số của
# File.Move, cái đó chỉ có từ .NET Core 3.0, không chạy được trên Windows
# PowerShell 5.1. Lần ghi đầu tiên (đích chưa tồn tại) dùng File.Move hai
# tham số: không có gì để thay thế, nhưng cũng không có gì để mất. Cả hai
# ném exception .NET thật (terminating, không phụ thuộc $ErrorActionPreference
# của caller) khi thất bại, nên `return` phía dưới không bao giờ chạy trên
# đường thất bại.
#
# Tham số backup của Replace KHÔNG được truyền $null trần: một $null trần
# marshal thành chuỗi rỗng khi bind vào tham số String của method .NET, và
# File.Replace ném "The path is not of a legal form" vì "" không phải path
# hợp lệ (không phải vì thiếu [NullString] -- kiểu đó có từ PowerShell 3.0,
# kể cả trên Windows PowerShell 5.1). [NullString]::Value tồn tại đúng để
# đi qua tình huống này: ép PowerShell truyền một null reference thật cho
# tham số String thay vì "". Không tạo backup -> không có gì phải dọn, và
# vì thế không có nguy cơ một file backup chứa secret cũ nằm lại vô thời
# hạn nếu bước dọn tự nó thất bại (AV/indexer giữ khoá tạm thời).
function Write-PwshSecretsFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][System.Collections.IDictionary]$Pairs,
        [Parameter(Mandatory)][string]$Path
    )

    $dir = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    $lines = @('# Generated by windows/lib/Secrets.psm1 -- do not edit, do not commit.')
    foreach ($name in $Pairs.Keys) {
        $escaped = [string]$Pairs[$name] -replace "'", "''"
        $lines  += ('$env:{0} = ''{1}''' -f $name, $escaped)
    }

    $tmp = Join-Path $dir ('.tmp.' + [System.IO.Path]::GetRandomFileName())
    try {
        Set-Content -LiteralPath $tmp -Value $lines -Encoding UTF8 -Force -ErrorAction Stop

        $me = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        Set-RestrictiveAcl -Path $tmp -Principal $me

        if (Test-Path -LiteralPath $Path) {
            [System.IO.File]::Replace($tmp, $Path, [NullString]::Value)
        } else {
            [System.IO.File]::Move($tmp, $Path)
        }

        # Đường Replace vừa vứt mất ACL đặt trên $tmp -- đặt lại trên đích.
        Set-RestrictiveAcl -Path $Path -Principal $me
    }
    finally {
        if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue }
    }

    return $Pairs.Count
}

# Mọi điều kiện thiếu đều `return $null` chứ không `throw`: hàm này chạy trong
# vòng lặp module của apply.ps1, và một máy chưa có khoá không được làm hỏng cả
# lượt apply. Cùng nguyên tắc với `agenix-reload` trên Unix.
function Update-PwshSecrets {
    [CmdletBinding()]
    param(
        [string]$RepoRoot   = (Join-Path $env:USERPROFILE '.nix'),
        [string]$Identity   = (Join-Path $env:USERPROFILE '.ssh\id_ed25519'),
        [string]$OutFile    = (Join-Path $env:LOCALAPPDATA 'pwsh-secrets\apikey.ps1'),
        [string]$AgeCommand = 'age'
    )

    $age = Get-Command $AgeCommand -ErrorAction SilentlyContinue
    if (-not $age) {
        Write-Warn "age not found ($AgeCommand) -- install it with scoop"
        return $null
    }

    if (-not (Test-Path -LiteralPath $Identity)) {
        Write-Skip "no age identity at $Identity"
        return $null
    }

    $ageFile = Join-Path $RepoRoot 'home-manager\programs\zsh\age.d\apikey.zsh.age'
    if (-not (Test-Path -LiteralPath $ageFile)) {
        Write-Warn "no secret file at $ageFile"
        return $null
    }

    # stderr của age đi vào file tạm chứ không vào $null: khi giải mã hỏng, mã
    # thoát một mình không nói được gì (khoá sai, khoá có passphrase, file
    # ciphertext hỏng đều là "exit 1"), mà cửa sổ tự nâng quyền của apply.ps1
    # thì rất dễ bị bỏ qua. Ghi ra file thay vì `2>&1` vào pipeline: `2>&1`
    # biến từng dòng stderr của native command thành ErrorRecord, và dưới
    # `$ErrorActionPreference = 'Stop'` (apply.ps1 đặt) cái đó tự nó ném lỗi.
    #
    # stderr CHỈ được in ở nhánh thất bại. Đường thành công không log gì thêm --
    # nội dung giải mã không bao giờ được đi ra console.
    $errFile = Join-Path ([System.IO.Path]::GetTempPath()) ('.age-err.' + [System.IO.Path]::GetRandomFileName())
    try {
        $global:LASTEXITCODE = 0
        # `2>` không đủ để trung hoà stderr: Windows PowerShell 5.1 vẫn dựng
        # ErrorRecord cho từng dòng stderr của native command TRƯỚC khi ghi ra
        # file, nên dưới `$ErrorActionPreference = 'Stop'` (apply.ps1 đặt) đúng
        # cái `age` chịu nói lý do lại ném terminating error và cướp mất nhánh
        # xử lý lỗi bên dưới -- ngược hẳn ý định. Hạ preference bên trong một
        # scriptblock `& { }` để phạm vi chỉ gói đúng lời gọi này, không rò sang
        # Write-PwshSecretsFile ở dưới (preference variable có scope động).
        $text = & {
            $ErrorActionPreference = 'Continue'
            & $age.Source -d -i $Identity $ageFile 2>$errFile
        }
        # Đọc rồi reset ngay: $LASTEXITCODE là biến toàn cục của cả tiến trình
        # PowerShell, không phải cục bộ hàm. Nếu để nguyên giá trị khác 0 ở đây,
        # nó sống sót qua phần còn lại của tiến trình -- kể cả runner Actions
        # (`shell: powershell`) tự `exit $LASTEXITCODE` sau khi script chạy xong,
        # nên một lần giải mã hỏng được xử lý đúng bên trong hàm này vẫn có thể
        # làm cả job CI báo fail dù Pester báo 0 test fail.
        $exitCode = $LASTEXITCODE
        $global:LASTEXITCODE = 0
        if ($exitCode -ne 0) {
            Write-Fail "age -d failed with exit code $exitCode"
            if (Test-Path -LiteralPath $errFile) {
                foreach ($line in @(Get-Content -LiteralPath $errFile -ErrorAction SilentlyContinue)) {
                    if ($line.Trim() -ne '') { Write-Fail "  age: $line" }
                }
            }
            return $null
        }
    }
    finally {
        if (Test-Path -LiteralPath $errFile) { Remove-Item -LiteralPath $errFile -Force -ErrorAction SilentlyContinue }
    }

    $pairs = ConvertFrom-ShellEnv -Text ($text -join "`n")
    if ($pairs.Count -eq 0) {
        Write-Warn 'decrypted successfully but found no assignments'
        return $null
    }

    Write-PwshSecretsFile -Pairs $pairs -Path $OutFile | Out-Null
    Write-OK "$($pairs.Count) secrets -> $OutFile"
    return $pairs.Count
}

Export-ModuleMember -Function ConvertFrom-ShellEnv, Write-PwshSecretsFile, Update-PwshSecrets
