# replace 'Ctrl+t' and 'Ctrl+r' with your preferred bindings:
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
# Oh My Posh init
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\wopian.omp.json" | Invoke-Expression

Import-Module Terminal-Icons
Import-Module ZLocation

# Set-PSReadLineOption -PredictionSource History
# Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
$conflicts = @("gc", "gl", "gp")
foreach ($alias in $conflicts) {
    if (Test-Path "alias:$alias") {
        Remove-Item "alias:$alias" -Force
    }
}
function v { nvim.exe }
function lzg { lazygit }
function lzd { lazydocker }
function ff { fastfetch }

function ga { git add $args }
function gc {
    if ($args.Count -eq 0) {
        Write-Warning "Commit message is required."
    }
    else {
        $message = $args -join " "
        git commit -m "$message"
    }
}
function gp { git push $args }
function gst { git status $args }
function gl { git pull $args }
function glog { 
    git log --graph --oneline --decorate --all 
}
function py { python $args }
# Set-Alias spy source .venv\bin\activate
function m { micromamba.exe }