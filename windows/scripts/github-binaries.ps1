
# --------------------------------------------------------
# Install kanata from GitHub releases (auto-detect arch)
# --------------------------------------------------------
$kanataVersion = "v1.11.0"
$kanataArch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "x64" }
$kanataDest = "$env:USERPROFILE\.local\bin\kanata.exe"
if (!(Test-Path $kanataDest)) {
    Write-Host "Installing kanata $kanataVersion ($kanataArch)..." -ForegroundColor Cyan
    $kanataZipUrl = "https://github.com/jtroo/kanata/releases/download/$kanataVersion/windows-binaries-$kanataArch.zip"
    $tmpZip = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "kanata_$kanataArch.zip")
    $tmpDir = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "kanata_extract")
    Invoke-WebRequest -Uri $kanataZipUrl -OutFile $tmpZip -UseBasicParsing
    Expand-Archive -Path $tmpZip -DestinationPath $tmpDir -Force
    New-Item -ItemType Directory -Force -Path (Split-Path $kanataDest) | Out-Null
    Copy-Item "$tmpDir\kanata_windows_gui_winIOv2_$kanataArch.exe" -Destination $kanataDest -Force
    Remove-Item $tmpZip -Force
    Remove-Item $tmpDir -Recurse -Force
    Write-Host "kanata $kanataVersion installed to $kanataDest" -ForegroundColor Green
} else {
    Write-Host "kanata already installed." -ForegroundColor Green
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
