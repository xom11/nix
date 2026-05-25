# Install scoop + packages not available in winget (kanata, stylua, im-select, yamlfmt).
# Run this in a NON-ADMIN PowerShell (scoop refuses to run as administrator).
#
# Usage: powershell -ExecutionPolicy Bypass -File install-scoop.ps1

$ErrorActionPreference = 'Stop'

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
    Write-Host "ERROR: this script must run as a regular user, not as administrator." -ForegroundColor Red
    Write-Host "Open a normal PowerShell (no 'Run as administrator') and re-run." -ForegroundColor Yellow
    exit 1
}

# 1. Install scoop if missing
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "==> Installing scoop..." -ForegroundColor Cyan
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-Expression (Invoke-RestMethod -Uri 'https://get.scoop.sh')
}

# 2. Tell scoop to use system 7-Zip if available (avoids the ARM64 pre_install bug
#    in scoop's bundled 7zip manifest). System 7-Zip comes from winget package 7zip.7zip.
if (Get-Command 7z -ErrorAction SilentlyContinue) {
    scoop config 7zipextract_use_external $true | Out-Null
    Write-Host "==> Using system 7-Zip ($(Get-Command 7z | Select-Object -ExpandProperty Source))" -ForegroundColor Green
} elseif (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "==> Recommended: 'winget install 7zip.7zip' to avoid scoop's ARM64 7zip bug." -ForegroundColor Yellow
}

# 3. Add 'extras' bucket for additional packages (im-select lives here)
$buckets = scoop bucket list 2>$null | ForEach-Object { $_.Name }
if ($buckets -notcontains 'extras') {
    Write-Host "==> Adding 'extras' bucket..." -ForegroundColor Cyan
    scoop bucket add extras
}

# 4. Install packages not in winget
$packages = @(
    'kanata'        # keyboard remapper CLI (jtroo/kanata)
    'stylua'        # Lua formatter
    'yamlfmt'       # YAML formatter
    'im-select'     # input method switcher (from extras bucket)
)

$installed = @(scoop list 6>$null | ForEach-Object { $_.Name } | Where-Object { $_ })
foreach ($pkg in $packages) {
    if ($installed -contains $pkg) {
        Write-Host "  SKIP $pkg" -ForegroundColor DarkGray
    } else {
        Write-Host "  scoop install $pkg" -ForegroundColor Blue
        scoop install $pkg
    }
}

Write-Host ""
Write-Host "Done. scoop tools are in $env:USERPROFILE\scoop\shims (already in PATH)." -ForegroundColor Green
