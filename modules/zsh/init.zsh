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


nu() {
  local config="${1:-nixos}"
  nix run github:nix-community/home-manager -- switch --impure -b backup --flake ~/nix#"${config}"
}

osu() {
  local config="${1:-nixos}"
  sudo nixos-rebuild switch --impure --flake ~/nix#"${config}"
}