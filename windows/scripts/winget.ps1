# --------------------------------------------------------
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Exit
}

# --------------------------------------------------------
# Install winget packages
# --------------------------------------------------------
$modules = @(
    "gerardog.gsudo"
    "Microsoft.PowerShell"
    "JanDeDobbeleer.OhMyPosh"
    # "Microsoft.PowerToys"
    "Discord.Discord"
    "Google.Chrome"
    "Microsoft.VisualStudioCode"
    "Tailscale.Tailscale"
    # "UniKey.UniKey"
    "VNGCorp.Zalo"
    "Brave.Brave"
    "9PFXXSHC64H3" # Raycast
    "Notion.Notion"

)

foreach ($module in $modules) {
    Write-Host "Installing $app..." -ForegroundColor Cyan
    
    winget install --id $app `
        -e `
        --silent `
        --accept-package-agreements `
        --accept-source-agreements
}

# --------------------------------------------------------
# Install PowerShell modules
# --------------------------------------------------------
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted -ErrorAction SilentlyContinue

$modules = @(
    "Terminal-Icons"
    "ZLocation"
    "PSReadLine"
)

foreach ($module in $modules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Write-Host "Installing $module..." -ForegroundColor Cyan
        Install-Module -Name $module -Force -AllowClobber
    }
    else {
        Write-Host "$module is already installed." -ForegroundColor Green
    }
}

# --------------------------------------------------------
# Install scoop modules
# --------------------------------------------------------
$modules = @(
    "bat"
    "fastfetch"
    "fzf"
    "gh"
    "git"
    "neovim"
    "oh-my-posh"
    "lazygit"
    "lazydocker"
    "ripgrep"
    "yazi"
)
foreach ($module in $modules) {
    Write-Host "Installing $module via scoop..." -ForegroundColor Cyan
    scoop install $module
}

Write-Host "Done!" -ForegroundColor Green
Read-Host "Press Enter to exit"
