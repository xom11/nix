
# delete all git fork remotes
alias delete_all_git_fork="
  gh repo list --fork --json nameWithOwner --limit 200 | \
  jq -r '.[].nameWithOwner' | \
  xargs -I {} gh repo delete {} --yes
"
