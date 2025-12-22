# --------------------------------------------------------
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Exit
}

# --------------------------------------------------------
# Install winget packages
# --------------------------------------------------------

winget source update
winget source reset --force
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
    Write-Host "Installing $module ..." -ForegroundColor Cyan
    
    winget install --id $module `
        -e `
        --silent `
        --accept-package-agreements `
        --accept-source-agreements
}

# --------------------------------------------------------
# Install PowerShell modules
# --------------------------------------------------------
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not (Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue)) {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser | Out-Null
}

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
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    try {
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
        Write-Host "Install Scoop sucess!" -ForegroundColor Green
    }
    catch {
        Write-Error "Error installing Scoop"
        Exit
    }
}

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + [System.Environment]::GetEnvironmentVariable("Path","Machine")

scoop install git
scoop bucket add extras

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
