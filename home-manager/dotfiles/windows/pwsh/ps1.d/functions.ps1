
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
