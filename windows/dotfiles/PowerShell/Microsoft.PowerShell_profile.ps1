# replace 'Ctrl+t' and 'Ctrl+r' with your preferred bindings:
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
# Oh My Posh init
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\wopian.omp.json" | Invoke-Expression

Import-Module Terminal-Icons
Import-Module ZLocation

# Set-PSReadLineOption -PredictionSource History
# Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

function v{nvim.exe}
Set-Alias lzg lazygit
Set-Alias lzd lazydocker
Set-Alias ff fastfetch

function ga {git add $args}
function gc {git commit -m $args}
function gp {git push}
function gst {git status}
function gl {git pull}

function py {python $args}
# Set-Alias spy source .venv\bin\activate
function m {micromamba.exe}