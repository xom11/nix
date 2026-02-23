if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -File `"$PSCommandPath`"" -Verb RunAs
    exit
}
$basePath = ".\..\.."
$homeManagerPath = "$basePath\home-manager"
$configsPath = "$basePath\configs"

# Define the list of source and target paths
$dotfiles = @(
    # PART: PowerToys
    @{
        src  = ".\PowerToys\settings.json";
        dest = "$env:LOCALAPPDATA\Microsoft\PowerToys\settings.json"
    }
  # PART: Windows Terminal
    @{
        src  = ".\WindowsTerminal\settings.json";
        dest = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    }
  # PART: PowerShell
    @{
        src  = ".\pwsh\Microsoft.PowerShell_profile.ps1";
        dest = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
    }
  # PART: pwsh
    @{
        src  = ".\pwsh\ps1.d";
        dest = "$env:USERPROFILE\Documents\PowerShell\ps1.d"
    }
  # PART: VSCode
    @{
        src  = "$homeManagerPath\dotfiles\vscode\settings.json";
        dest = "$env:APPDATA\Code\User\settings.json"
    }
    @{
        src  = "$homeManagerPath\dotfiles\vscode\keybindings.json";
        dest = "$env:APPDATA\Code\User\keybindings.json"
    }
  # PART: WezTerm
    @{
        src  = "$homeManagerPath\dotfiles\wezterm\wezterm.lua";
        dest = "$env:USERPROFILE\.config\wezterm\wezterm.lua"
    }
  # PART: SSH
    @{
        src  = "$homeManagerPath\programs\ssh\config";
        dest = "$env:USERPROFILE\.ssh\config"
    }
  # PART: Neovim
    @{
        src  = "$homeManagerPath\programs\lazyvim\init.lua";
        dest = "$env:USERPROFILE\AppData\Local\nvim\init.lua"
    }
    @{
        src  = "$homeManagerPath\programs\lazyvim\lazy-lock.json";
        dest = "$env:USERPROFILE\AppData\Local\nvim\lazy-lock.json"
    }
    @{
        src  = "$homeManagerPath\programs\lazyvim\lua\plugins";
        dest = "$env:USERPROFILE\AppData\Local\nvim\lua\plugins"
    }
    @{
        src  = "$homeManagerPath\programs\lazyvim\lua\config\lazy.lua";
        dest = "$env:USERPROFILE\AppData\Local\nvim\lua\config\lazy.lua"
    }
  # share lua config with nixvim
    @{
        src  = "$homeManagerPath\programs\nixvim\lua\config\keymaps.lua";
        dest = "$env:USERPROFILE\AppData\Local\nvim\lua\config\keymaps.lua"
    }
    @{
        src  = "$homeManagerPath\programs\nixvim\lua\config\options.lua";
        dest = "$env:USERPROFILE\AppData\Local\nvim\lua\config\options.lua"
    }
    @{
        src  = "$homeManagerPath\programs\nixvim\lua\extras";
        dest = "$env:USERPROFILE\AppData\Local\nvim\lua\extras"
    }
    @{
        src  = "$homeManagerPath\programs\nixvim\lua\opts";
        dest = "$env:USERPROFILE\AppData\Local\nvim\lua\opts"
    }
  # PART: Yazi
    @{
        src  = "$homeManagerPath\programs\yazi\yazi.d";
        dest = "$env:APPDATA\yazi\config"
    }
)

# Sửa lại phần xử lý đường dẫn nguồn (Source Path) để tránh lỗi định dạng
foreach ($item in $dotfiles) {
    $source = $item.src
    # Chuyển đổi đường dẫn tương đối thành tuyệt đối chuẩn hơn
    if ($source.StartsWith(".\")) {
        $source = Join-Path $PSScriptRoot $source.Substring(2)
    } elseif ($source.StartsWith("$basePath")) {
         # Đảm bảo các biến $basePath được resolve đầy đủ
         $source = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($source)
    }

    $target = $item.dest
    Write-Host "Processing: $source -> $target" -ForegroundColor Cyan

    # 1. Kiểm tra nguồn có tồn tại không
    if (-not (Test-Path $source)) {
        Write-Warning "Source not found: $source. Skipping..."
        continue
    }

    # 2. Tạo thư mục cha của Target nếu chưa có
    $targetDir = Split-Path $target
    if (-not (Test-Path $targetDir)) {
        New-Item -Path $targetDir -ItemType Directory -Force | Out-Null
    }

    # 3. Xóa Target cũ (Xử lý đặc biệt cho Symlink)
    if (Test-Path $target) {
        # Nếu là thư mục, dùng -Recurse, nếu là file dùng -Force
        Remove-Item -Path $target -Force -Recurse -ErrorAction SilentlyContinue
    }

    # 4. Tạo Symbolic Link
    try {
        # Xác định target là file hay thư mục để tránh lỗi logic của Windows
        $itemType = "SymbolicLink"
        if (Test-Path $source -PathType Container) {
            # Một số phiên bản Windows yêu cầu gọi trực tiếp cmd để tạo link thư mục ổn định hơn
            cmd /c mklink /D "$target" "$source"
        } else {
            New-Item -Path $target -ItemType $itemType -Value $source -Force | Out-Null
        }
        Write-Host "Successfully linked!" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to create link at $target: $_"
    }
    Write-Host "-----------------------------------"
}
