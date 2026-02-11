alias f='fzf'
alias ff='fastfetch'
alias cat='bat --paging=never --plain'
alias fp='fzf --preview="bat --color=always {}"'
alias vf='nvim $(fzf -m --preview="bat --color=always {}")'
alias ls='eza --icons --group-directories-first'
alias lzg='lazygit'
alias lzd='lazydocker'
alias lzv='NVIM_APPNAME=lazyvim nvim'
alias v='nvim'
alias vcf='cd ~/.config/nvim && nvim'
alias rsyncgit='rsync -av --exclude ".git/" --exclude-from=".gitignore"'

# git https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/README.md
alias g='git'
alias ga='git add'
alias gl='git pull'
alias gp='git push'
alias gc='git commit -m'
alias gst='git status'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --oneline --graph --decorate'

# python
alias py='python'
alias spy='source .venv/bin/activate'
alias m='micromamba'

# uvx
alias nvitop='uvx nvitop'
alias btcli='uvx --from bittensor-cli btcli'

# uv https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/uv/README.md
alias uva='uv add'
alias uvl='uv lock'
alias uvi='uv init'
alias uvr='uv run'
alias uvrm='uv remove'
alias uvs='uv sync'
alias uvsr='uv sync --refresh'
alias uvsu='uv sync --upgrade'
alias uvv='uv venv'

# kitty
alias kitty-opacity='kitty @ set-background-opacity'

# tmux https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/tmux/README.md
alias tl='tmux ls'
# alias tn='tmux new -s '
tn() {
  local session_name="${1:-$(basename "$PWD")}"

  if [ -n "$TMUX" ]; then
    tmux -u new-session -d -s "$session_name"
    tmux -u switch-client -t "$session_name"
  else
    tmux new-session -s "$session_name"
  fi
}
alias ts='tmux switch -t'
alias ta='tmux -u attach -t'
alias tksv='tmux kill-server'
alias tkss='tmux kill-session -t '

# ai
alias aie='aichat -e'
alias air='aichat -r'

# nix
alias u='update'
