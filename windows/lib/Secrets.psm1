# Đọc file secret dùng chung với macOS/Linux. Nguồn là cú pháp shell
# (`export K="V"`) vì đó là thứ zsh source trực tiếp; ở đây `export` chỉ là
# tiền tố tuỳ chọn cần bỏ qua.
#
# Value được coi là chữ thuần: không nội suy `$`, backtick hay `$(...)`. Luật đó
# ghi ở CLAUDE.md. Sinh ra chuỗi nháy đơn của PowerShell nên kể cả khi luật bị
# vi phạm cũng không có gì được thực thi.
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
