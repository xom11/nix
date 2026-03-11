
# --------------------------------------------------------
# Install npm global packages
# --------------------------------------------------------

# Ensure Node.js / npm is available
if (!(Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host "npm not found. Installing Node.js via scoop..." -ForegroundColor Yellow
    if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Error "scoop is required. Run scoop.ps1 first."
        exit 1
    }
    scoop install nodejs
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine")
}

Write-Host "npm version: $(npm --version)" -ForegroundColor Green

$packages = @(
    "@anthropic-ai/claude-code"   # Claude Code CLI
    "@google/gemini-cli"          # Gemini CLI

    # "prettier"                    # Code formatter
    # "typescript"                  # TypeScript compiler
    # "tsx"                         # Run TypeScript directly
)

foreach ($pkg in $packages) {
    npm list -g $pkg --depth=0 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Already installed: $pkg" -ForegroundColor DarkGray
    } else {
        Write-Host "Installing $pkg ..." -ForegroundColor Cyan
        npm install -g $pkg
    }
}

Write-Host "`nDone! Installed packages:" -ForegroundColor Green
npm list -g --depth=0

# Add ~/.local/bin to User PATH permanently so all apps (Neovim, terminals, etc.) can find npm globals
$localBin = "$env:USERPROFILE\.local\bin"
$userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($userPath -notlike "*$localBin*") {
    [Environment]::SetEnvironmentVariable("PATH", "$localBin;$userPath", "User")
    Write-Host "`nAdded $localBin to User PATH permanently." -ForegroundColor Green
}
