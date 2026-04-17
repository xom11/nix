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
        src  = "$homeManagerPath\programs\nvim\lua\init.lua";
        dest = "$env:USERPROFILE\AppData\Local\nvim\init.lua"
    }
    @{
        src  = "$homeManagerPath\programs\nvim\lua";
        dest = "$env:USERPROFILE\AppData\Local\nvim\lua"
    }
    # PART: Claude
    @{
        src  = "$homeManagerPath\dotfiles\claude\claude.d\commands";
        dest = "$env:USERPROFILE\.claude\commands"
    }
    # PART: Aichat
    @{
        src  = "$homeManagerPath\dotfiles\aichat\aichat.d\roles";
        dest = "$env:APPDATA\aichat\roles"
    }
    # PART: Yazi
    @{
        src  = "$homeManagerPath\programs\yazi\yazi.d";
        dest = "$env:APPDATA\yazi\config"
    }
)

$ok = 0; $fail = 0

foreach ($item in $dotfiles) {
    $source = $item.src
    if ($source -like ".\*") {
        $source = Join-Path $PSScriptRoot $source.Substring(2)
    }
    $target = $item.dest

    if (-not (Test-Path $source)) {
        Write-Host "SKIP  $source" -ForegroundColor Yellow
        $fail++
        continue
    }

    $targetDir = Split-Path $target
    if (-not (Test-Path $targetDir)) {
        New-Item -Path $targetDir -ItemType Directory -Force | Out-Null
    }

    if (Test-Path $target) {
        Remove-Item -Path $target -Force -Recurse
    }

    try {
        New-Item -Path $target -ItemType SymbolicLink -Value $source -Force | Out-Null
        Write-Host "OK    $target" -ForegroundColor Green
        $ok++
    }
    catch {
        Write-Host "FAIL  $target`n      $_" -ForegroundColor Red
        $fail++
    }
}

Write-Host "`nDone: $ok linked, $fail failed." -ForegroundColor Cyan
Read-Host "Press Enter to exit..."

