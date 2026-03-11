
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
    "kanata"
    "yazi"
    "autohotkey"

    "shfmt"
    "yamlfmt"
    "stylua"
)
foreach ($module in $modules) {
    Write-Host "Installing $module via scoop..." -ForegroundColor Cyan
    scoop install $module
}

# --------------------------------------------------------
# Install im-select (input method switcher for Neovim)
# --------------------------------------------------------
$imSelectDest = "$env:USERPROFILE\.local\bin\im-select.exe"
if (!(Test-Path $imSelectDest)) {
    Write-Host "Installing im-select.exe..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path (Split-Path $imSelectDest) | Out-Null
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/daipeihust/im-select/master/win/out/x64/im-select.exe" -OutFile $imSelectDest -UseBasicParsing
    Write-Host "im-select.exe installed to $imSelectDest" -ForegroundColor Green
} else {
    Write-Host "im-select.exe already installed." -ForegroundColor Green
}

