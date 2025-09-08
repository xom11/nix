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
alias gu='git pull && git add . && git commit -m "update" && git push'


# python
alias py='python'
alias spy='source .venv/bin/activate'
alias m='micromamba'
alias mamba='micromamba'

alias nvitop='uvx nvitop'
alias btcli='uvx --from bittensor-cli btcli'
