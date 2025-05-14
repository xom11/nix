# export PATH="$PATH:$HOME/.local/bin"
# export PATH="/run/wrappers/bin"
# export ZSH="$HOME/.oh-my-zsh"
# export XDG_CONFIG_HOME="$HOME/.config"
# export NIX_CONF_DIR=$HOME/.config/nix
# export NIX_PATH="$HOME/gnome/nix"
export PATH=/run/wrappers/bin:$PATH

autoload -Uz compinitcompinit

ZSH_THEME="robbyrussell"
plugins=(git web-search extract copyfile copypath fzf z uv)
source $ZSH/oh-my-zsh.sh
# source $HOME/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# source $HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# source $HOME/.nix-profile/share/zsh-vi-mode/zsh-vi-mode.zsh

# if command -v uv &> /dev/null; then
#   eval "$(uv generate-shell-completion zsh)"
# fi
# if command -v zoxide &> /dev/null; then
#   eval "$(zoxide init zsh)"
# fi
if command -v atuin &> /dev/null; then
  eval "$(atuin init zsh)"
fi

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}


if (( $+commands[z] )) || (( $+functions[z] )); then
    alias cd='z'
fi
alias f=fzf

if (( $+commands[bat] )); then
    alias cat='bat --paging=never --plain'
    alias fp='fzf --preview="bat --color=always {}"'
    alias vf='nvim $(fzf -m --preview="bat --color=always {}")'
elif (( $+commands[batcat] )); then
    alias cat='batcat --paging=never --plain'
    alias fp='fzf --preview="batcat --color=always {}"'
    alias vf='nvim $(fzf -m --preview="batcat --color=always {}")'
else
    alias fp='fzf --preview="cat {}"'
    alias vf='nvim $(fzf -m --preview="cat {}")'
fi
if (( $+commands[eza] )) || (( $+functions[eza] )); then
    alias ls='eza --icons --group-directories-first'
fi
alias v=nvim
alias vcf='cd ~/.config/nvim && nvim'
alias vz='nvim ~/.zshrc'
alias sz='source ~/.zshrc'
alias spy='source .venv/bin/activate'
alias cc='conda create -p ./.venv python==3.12'
alias ca='conda activate ./.venv'
alias gcg='git config --global user.name khanhkhanhlele && git config --global user.email namkhanh20xx@gmail.com'
alias gcl='git config --local user.name khanhkhanhlele && git config --local user.email namkhanh20xx@gmail.com'
alias gu='git pull && git add . && git commit -m "update" && git push'
alias py='python3' 
alias py310='python3.10'
alias nixupdate="nix run github:nix-community/home-manager -- switch --impure --flake -b backup ~/nix#local"
alias nixosupdate="sudo nixos-rebuild switch --impure --flake ~/nix#local"

t() {
  if [ -z "$TMUX" ]; then
    tmux attach -t "$1" || tmux new -s "$1"
  else
    tmux new-window -n "$1"
  fi
}
