
# Teach zoxide about the dotfile directories in $HOME. This used to run on every shell start,
# spawning one zoxide process per directory (10 here, ~230 ms) to re-add entries it already
# had. Run it by hand after creating a new dotfile directory.
function Update-ZoxideSeed {
    if (-not (Get-Command zoxide -ErrorAction SilentlyContinue)) {
        Write-Warning 'zoxide not installed'
        return
    }
    $dirs = Get-ChildItem -Path $HOME -Directory -Force -Filter '.*'
    $dirs | ForEach-Object { zoxide add $_.FullName }
    Write-Host "seeded $($dirs.Count) directories into zoxide"
}

# Basic commands
function which($name) { Get-Command $name -ErrorAction SilentlyContinue | Select-Object Definition }
function touch($file) { "" | Out-File $file -Encoding ASCII }

# Common editing needs
function Get-ElevateCommand {
    # Windows 11's own sudo, switched to inline mode by windows/scripts/tweaks.ps1.
    # gsudo is the fallback where that has not been run.
    foreach ($c in 'sudo', 'gsudo') {
        $cmd = Get-Command $c -CommandType Application -ErrorAction SilentlyContinue
        if ($cmd) { return $cmd.Source }
    }
    return $null
}

function Edit-Hosts {
    $editor   = if ($env:EDITOR) { $env:EDITOR } else { 'notepad' }
    $hostFile = Join-Path $env:windir 'system32\drivers\etc\hosts'
    $elevate  = Get-ElevateCommand
    if (-not $elevate) {
        Write-Warning 'neither sudo nor gsudo is available'
        return
    }
    & $elevate $editor $hostFile
}

function Edit-Profile {
    $editor = if ($env:EDITOR) { $env:EDITOR } else { 'notepad' }
    & $editor $PROFILE
}

### File system
### ----------------------------
# Create a new directory and enter it
function CreateAndSet-Directory([string]$path) {
    New-Item $path -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    Set-Location $path
}

# Convert a number of bytes to a readable size (12K, 5M)
function Convert-ToDiskSize {
    param($bytes, $precision = '0')
    foreach ($size in ('B', 'K', 'M', 'G', 'T')) {
        if (($bytes -lt 1000) -or ($size -eq 'T')) {
            $bytes = ($bytes).ToString("F0$precision")
            return "${bytes}${size}"
        }
        $bytes /= 1KB
    }
}

# Total size of a directory, like `du -sh`. The previous version declared a -path parameter
# and then ignored it, always measuring the current directory instead.
function Get-DiskUsage([string]$path = (Get-Location).Path) {
    $sum = (Get-ChildItem -LiteralPath $path -Recurse -File -ErrorAction SilentlyContinue |
        Measure-Object -Property Length -Sum).Sum
    Convert-ToDiskSize $sum 1
}

### Environment
### ----------------------------
# Reload $env from the registry
function Refresh-Environment {
    $locations = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
                 'HKCU:\Environment'

    $locations | ForEach-Object {
        $k = Get-Item $_
        $k.GetValueNames() | ForEach-Object {
            $name = $_
            Set-Item -Path Env:\$name -Value $k.GetValue($name)
        }
    }

    $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [System.Environment]::GetEnvironmentVariable('Path', 'User')
}

# Set a permanent environment variable and load it into $env
function Set-Environment([string]$variable, [string]$value) {
    # Written straight to the registry: SetEnvironmentVariable blocks on HWND_BROADCAST.
    Set-ItemProperty 'HKCU:\Environment' $variable $value
    Set-Item -Path Env:\$variable -Value $value
}

# Prepend-EnvPath / Append-EnvPath and their *IfExists pairs used to sit here. Nothing in the
# repo called them and they are not names anyone types at a prompt -- leftovers from when this
# profile built PATH itself. PATH now comes from the registry (Refresh-Environment above, or
# `$env:PATH = "...;$env:PATH"` inline, which is shorter than the helper was).

# ----------------------------
# Secrets
# ----------------------------

# Giải mã lại secret và nạp thẳng vào shell đang chạy. `$env:` ánh xạ vào
# environment block của tiến trình, nên khác Unix -- ở đó `agenix-reload` chỉ
# ghi lại file, shell đang mở phải source lại.
#
# Import-Module nằm trong thân hàm để không tốn gì lúc mở shell.
function Update-Secrets {
    $repo = Join-Path $env:USERPROFILE '.nix'
    Import-Module (Join-Path $repo 'windows\lib\Secrets.psm1') -Force
    $n = Update-PwshSecrets -RepoRoot $repo
    if ($null -eq $n) { return }
    $file = Join-Path $env:LOCALAPPDATA 'pwsh-secrets\apikey.ps1'
    if (Test-Path -LiteralPath $file) { . $file }
}
Set-Alias agenix-reload Update-Secrets

# ----------------------------
# Caffeinate
# ----------------------------

# `caffeinate on` giữ máy không ngủ mà vẫn để màn hình tắt theo timeout của nó;
# `caffeinate off` trả lại như cũ. Tồn tại vì một lý do rất cụ thể của máy này:
# `powercfg /a` chỉ liệt kê **Standby (S0 Low Power Idle) Network Disconnected**,
# còn bản giữ mạng thì "disabled by policy" -- nên hễ ngủ là Tailscale rụng và SSH
# đứt. Thay vì tắt sleep vĩnh viễn (tốn pin), bật cái này lúc cần với tới từ xa.
#
# KHÔNG trùng với Keep Awake của look, và đừng bật cả hai. look đặt
# `ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED`
# (`qactions/controls/keepawake_windows.rs`), tức nó giữ luôn MÀN HÌNH -- khoá máy
# xong màn hình khoá vẫn sáng. Cái ở đây cố ý bỏ cờ display ra.
#
# Thông báo in ra để tiếng Anh, theo lệ phần còn lại của file: qua SSH console
# codepage không phải UTF-8 nên chữ có dấu ra thành `B?T`. Chú thích thì không in
# nên giữ tiếng Việt được.

function Get-CaffeinatePidFile { Join-Path $env:LOCALAPPDATA 'caffeinate\pid' }

function Get-CaffeinateProcess {
    $pidFile = Get-CaffeinatePidFile
    if (-not (Test-Path -LiteralPath $pidFile)) { return $null }

    $procId = 0
    if (-not [int]::TryParse((Get-Content -LiteralPath $pidFile -Raw).Trim(), [ref]$procId)) { return $null }
    if (-not (Get-Process -Id $procId -ErrorAction SilentlyContinue)) { return $null }

    # Windows tái sử dụng PID, nên "có tiến trình mang số này" chưa đủ -- phải thấy
    # đúng worker trong command line mới tin.
    $cmd = (Get-CimInstance Win32_Process -Filter "ProcessId = $procId" -ErrorAction SilentlyContinue).CommandLine
    if ($cmd -notlike '*caffeinate-worker.ps1*') { return $null }

    Get-Process -Id $procId
}

function Start-Caffeinate {
    [CmdletBinding()]
    param([int]$Minutes = 0)

    $running = Get-CaffeinateProcess
    if ($running) {
        Write-Host "caffeinate: already on (PID $($running.Id))"
        return
    }

    $worker = Join-Path $PSScriptRoot 'caffeinate-worker.ps1'
    if (-not (Test-Path -LiteralPath $worker)) {
        Write-Warning "caffeinate: worker not found at $worker"
        return
    }

    # Start-Process KHÔNG dùng được ở đây, và chỗ này đã đo trên a14 17/08/2026.
    # sshd gom tiến trình con vào job object của phiên, nên worker chết ngay lúc
    # ngắt SSH: đo được `alive=False` và power request biến mất, trong khi lệnh bật
    # vẫn báo thành công. Nhờ WMI đẻ hộ thì cha nó là WmiPrvSE, nằm ngoài job đó,
    # và nó sống qua cả lúc đóng phiên.
    $exe     = (Get-Process -Id $PID).Path
    $cmdArgs = '-NoProfile -NoLogo -File "{0}" -Minutes {1}' -f $worker, $Minutes
    $r = Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{
        CommandLine = '"{0}" {1}' -f $exe, $cmdArgs
    }
    if ($r.ReturnValue -ne 0) {
        Write-Warning "caffeinate: could not spawn worker (Win32_Process.Create returned $($r.ReturnValue))"
        return
    }

    $pidFile = Get-CaffeinatePidFile
    New-Item -ItemType Directory -Path (Split-Path $pidFile) -Force | Out-Null
    Set-Content -LiteralPath $pidFile -Value $r.ProcessId -Encoding ASCII

    $span = if ($Minutes -gt 0) { "for $Minutes min" } else { 'until stopped' }
    Write-Host "caffeinate: ON $span (PID $($r.ProcessId)) -- the display still turns off"
}

function Stop-Caffeinate {
    $p       = Get-CaffeinateProcess
    $pidFile = Get-CaffeinatePidFile
    if (-not $p) {
        Remove-Item -LiteralPath $pidFile -ErrorAction SilentlyContinue
        Write-Host 'caffeinate: already off'
        return
    }
    Stop-Process -Id $p.Id -Force
    Remove-Item -LiteralPath $pidFile -ErrorAction SilentlyContinue
    Write-Host "caffeinate: OFF (stopped PID $($p.Id))"
}

function Get-CaffeinateStatus {
    $p = Get-CaffeinateProcess
    if ($p) {
        Write-Host "caffeinate: ON (PID $($p.Id))"
    } else {
        Write-Host 'caffeinate: OFF'
    }

    # Nguồn chân lý là power request, không phải tiến trình: một worker sống mà đặt
    # cờ hụt trông y hệt một worker chạy đúng. Đọc đúng dòng SYSTEM của powercfg.
    $lines = @(powercfg /requests)
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Trim() -eq 'SYSTEM:') {
            Write-Host ('  powercfg SYSTEM: ' + $lines[$i + 1].Trim())
            break
        }
    }
}

function caffeinate {
    param(
        [ValidateSet('on', 'off', 'status')][string]$Action = 'status',
        [int]$Minutes = 0
    )
    switch ($Action) {
        'on'     { Start-Caffeinate -Minutes $Minutes }
        'off'    { Stop-Caffeinate }
        'status' { Get-CaffeinateStatus }
    }
}
