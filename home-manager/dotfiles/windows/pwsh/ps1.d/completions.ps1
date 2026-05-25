# GitHub CLI (gh)
if (Get-Command gh -ErrorAction SilentlyContinue) {
    gh completion -s powershell | Out-String | Invoke-Expression
}
# Docker
if (Get-Command docker -ErrorAction SilentlyContinue) {
    docker completion powershell | Out-String | Invoke-Expression
}
# Git
Import-Module posh-git
