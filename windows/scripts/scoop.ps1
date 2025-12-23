
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
    "kanata"
    "yazi"
    "autohotkey"
)
foreach ($module in $modules) {
    Write-Host "Installing $module via scoop..." -ForegroundColor Cyan
    scoop install $module
}
