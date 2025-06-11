y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

t() {
    if [ -z "$TMUX" ]; then
        tmux attach -t "$1" || tmux new -s "$1"
    else
        tmux new-window -n "$1"
    fi
}
bindkey -M emacs '^R' fzf-history-widget
bindkey -M viins '^R' fzf-history-widget
bindkey -M vicmd '^R' fzf-history-widget