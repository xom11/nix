
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

    "prettier"                    # Code formatter
    "typescript"                  # TypeScript compiler
    "tsx"                         # Run TypeScript directly
)

foreach ($pkg in $packages) {
    Write-Host "Installing $pkg ..." -ForegroundColor Cyan
    npm install -g $pkg
}

Write-Host "`nDone! Installed packages:" -ForegroundColor Green
npm list -g --depth=0
