Import-Module Terminal-Icons
Invoke-Expression (& { (zoxide init powershell | Out-String) })
# Seed zoxide with dotfile directories in home
Get-ChildItem -Path $HOME -Directory -Force -Filter '.*' | ForEach-Object { zoxide add $_.FullName }
Import-Module PSFzf
# replace 'Ctrl+t' and 'Ctrl+r' with your preferred bindings:
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
# Oh My Posh init
oh-my-posh init pwsh --config "$PSScriptRoot\ps1.d\theme.json" | Invoke-Expression


# Set-PSReadLineOption -PredictionSource History
# Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

$ModulesDir = Join-Path (Split-Path $PSCommandPath) "ps1.d"

if (Test-Path $ModulesDir) {
    $files = Get-ChildItem -Path $ModulesDir -Filter *.ps1
    foreach ($file in $files) {
        . $file.FullName 
    }
}
