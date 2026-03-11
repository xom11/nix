
# --------------------------------------------------------
# Install scoop modules
# --------------------------------------------------------
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction SilentlyContinue

if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    try {
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
        Write-Host "Install Scoop sucess!" -ForegroundColor Green
    }
    catch {
        Write-Error "Error installing Scoop"
        exit
    }
}

$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine")

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
    "autohotkey"

    "shfmt"
    "yamlfmt"
    "stylua"
)
foreach ($module in $modules) {
    $installed = scoop list $module 2>&1 | Select-String $module
    if ($installed) {
        Write-Host "Already installed: $module" -ForegroundColor DarkGray
    } else {
        Write-Host "Installing $module via scoop..." -ForegroundColor Cyan
        scoop install $module
    }
}

