y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

t() {
    if [ -z "$1" ]; then
        SESSION_NAME="0"
    else
        SESSION_NAME="$1"
    fi

    if [ -z "$TMUX" ]; then
        tmux attach -t "$SESSION_NAME" || tmux new -s "$SESSION_NAME"
    else
        tmux new-window -n "$SESSION_NAME"
    fi
}

_uv_run_mod() {
    if [[ "$words[2]" == "run" && "$words[CURRENT]" != -* ]]; then
        _arguments '*:filename:_files -g "*.py"'
    else
        _uv "$@"
    fi
}
compdef _uv_run_mod uv
