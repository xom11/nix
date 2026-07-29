# Loaded from the profile's deferred (first-idle) block, not by the startup path.
# `gh completion` shells out and emits ~1500 lines that then have to be parsed; doing that
# on every start cost ~900 ms together with posh-git, which is why both live out here now.

# GitHub CLI (gh) -- cached, same scheme as zoxide/oh-my-posh in the profile.
if (Get-Command Import-CachedInit -ErrorAction SilentlyContinue) {
    Import-CachedInit -Name 'gh' -Command 'gh' -Generate { gh completion -s powershell }
} elseif (Get-Command gh -ErrorAction SilentlyContinue) {
    gh completion -s powershell | Out-String | Invoke-Expression
}

# Docker
if (Get-Command docker -ErrorAction SilentlyContinue) {
    docker completion powershell | Out-String | Invoke-Expression
}

# Git argument completion. The prompt does not need this -- oh-my-posh renders git status
# itself -- so posh-git is only here for tab completion.
# -Global because this file is dot-sourced from the profile's deferred event action, whose
# scope is thrown away as soon as it returns.
Import-Module posh-git -Global -ErrorAction SilentlyContinue
