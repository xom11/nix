alias f='fzf'
alias ff='fastfetch'
alias cat='bat --paging=never --plain'
alias fp='fzf --preview="bat --color=always {}"'
alias vf='nvim $(fzf -m --preview="bat --color=always {}")'
alias ls='eza --icons --group-directories-first'
alias lzg='lazygit'
alias lzd='lazydocker'
alias v='nvim'
alias vcf='cd ~/.config/nvim && nvim'
alias rsyncgit='rsync -av --exclude ".git/" --exclude-from=".gitignore"'

# git
alias g='git'
alias ga='git add .'
alias gl='git pull'
alias gp='git push'
alias gc='git commit -m'
alias gtest='git test'


# python
alias py='python'
alias spy='source .venv/bin/activate'
alias m='micromamba'
alias mamba='micromamba'

# uvx
alias nvitop='uvx nvitop'
alias btcli='uvx --from bittensor-cli btcli'

# kitty
alias kitty-opacity='kitty @ set-background-opacity'

# tmux
alias tls='tmux ls'
alias ta='tmux attach -t'
alias tk='tmux kill-session -t'
alias tn='tmux new -s'

# kanata
alias rk='sudo launchctl unload /Library/LaunchDaemons/org.nixos.kanata.plist; sudo launchctl load /Library/LaunchDaemons/org.nixos.kanata.plist'