# replace 'Ctrl+t' and 'Ctrl+r' with your preferred bindings:
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
# Oh My Posh init
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\wopian.omp.json" | Invoke-Expression

Import-Module Terminal-Icons
Import-Module ZLocation

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