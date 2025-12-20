
$conflicts = @("gc", "gl", "gp", "gu")
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
function gu {
    if ($args.Count -eq 0) {
        $commit_msg = "update"
    } else {
        $commit_msg = $args -join " "
    }

    git pull && git add . && git commit -m "$commit_msg" && git push
    Write-Host "Git updated completed." -ForegroundColor Green
}
function glog { 
    git log --graph --oneline --decorate --all 
}
function py { python $args }
# Set-Alias spy source .venv\bin\activate
function m { micromamba.exe }