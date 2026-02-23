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

foreach ($item in $dotfiles) {
    $source = $item.src
    if ($source -like ".\*") {
        $source = Join-Path $PSScriptRoot $source.Substring(2)
    }
    $target = $item.dest

    Write-Host "Processing: $($source) -> $($target)" -ForegroundColor Cyan

    # 1. Check if source exists
    if (-not (Test-Path $source)) {
        Write-Warning "Source not found: $source. Skipping..."
        continue
    }

    # 2. Ensure target parent directory exists
    $targetDir = Split-Path $target
    if (-not (Test-Path $targetDir)) {
        New-Item -Path $targetDir -ItemType Directory -Force | Out-Null
        Write-Host "Created directory: $targetDir" -ForegroundColor Gray
    }

    # 3. Remove existing file/folder/symlink at target
    if (Test-Path $target) {
        Remove-Item -Path $target -Force -Recurse
        Write-Host "Removed existing target: $target" -ForegroundColor Yellow
    }

    # 4. Create Symbolic Link
    try {
        New-Item -Path $target -ItemType SymbolicLink -Value $source -Force | Out-Null
        Write-Host "Successfully linked!" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to create link: $_"
    }
    Write-Host "-----------------------------------"
}

Write-Host "All done!" -ForegroundColor Magenta
Read-Host "Press Enter to exit..."

