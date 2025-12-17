# --------------------------------------------------------
# 1. Auto-elevate to Administrator (Sudo)
# --------------------------------------------------------
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Exit
}

# --------------------------------------------------------
# 2. List of App IDs (Find IDs via 'winget search <name>')
# --------------------------------------------------------
$apps = @(
    "gerardog.gsudo",
    "Git.Git",

    "Discord.Discord",
    "Google.Chrome",
    "Microsoft.VisualStudioCode",
    "Tailscale.Tailscale",
    "UniKey.UniKey",
    "VNGCorp.Zalo",
    "Brave.Brave",
    "9PFXXSHC64H3", # Raycast

)

# --------------------------------------------------------
# 3. Install Loop (Silent & Auto-accept agreements)
# --------------------------------------------------------
foreach ($app in $apps) {
    Write-Host "Installing $app..." -ForegroundColor Cyan
    
    winget install --id $app `
        -e `
        --silent `
        --accept-package-agreements `
        --accept-source-agreements
}

Write-Host "Done!" -ForegroundColor Green
Read-Host "Press Enter to exit"