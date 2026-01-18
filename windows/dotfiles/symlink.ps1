if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -File `"$PSCommandPath`"" -Verb RunAs
    exit
}
# Define the list of source and target paths
$dotfiles = @(
    @{
        src  = ".\PowerToys\settings.json";
        dest = "$env:LOCALAPPDATA\Microsoft\PowerToys\settings.json"
    }
    @{
        src  = ".\WindowsTerminal\settings.json";
        dest = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    }
    @{
        src  = ".\pwsh\Microsoft.PowerShell_profile.ps1";
        dest = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
    }
    @{
        src  = ".\pwsh\ps1.d";
        dest = "$env:USERPROFILE\Documents\PowerShell\ps1.d"
    }
    @{
        src  = ".\..\..\home-manager\dotfiles\vscode\settings.json";
        dest = "$env:APPDATA\Code\User\settings.json"
    }
    @{
        src  = ".\..\..\home-manager\dotfiles\vscode\keybindings.json";
        dest = "$env:APPDATA\Code\User\keybindings.json"
    }
    @{
        src  = ".\..\..\home-manager\dotfiles\wezterm\wezterm.lua";
        dest = "$env:USERPROFILE\.config\wezterm\wezterm.lua"
    }
    @{
        src  = ".\..\..\home-manager\programs\ssh\config";
        dest = "$env:USERPROFILE\.ssh\config"
    }
    @{
        src  = ".\..\..\configs\lazy.nvim";
        dest = "$env:USERPROFILE\AppData\Local\nvim"
    }
    @{
        src  = ".\..\..\home-manager\programs\yazi\yazi.d";
        dest = "$env:APPDATA\yazi\config"
    }
    # @{
    #     src  = "$HOME\dotfiles\nvim";
    #     dest = "$AppData\Local\nvim"
    # }
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
