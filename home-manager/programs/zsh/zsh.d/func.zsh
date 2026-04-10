y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

gu() {
  if [ -z "$1" ]; then
    commit_msg="update"
  else
    commit_msg="$@" 
  fi

  git pull && \
  git add . && \
  git commit -m "$commit_msg" && \
  git push
}

_uv_run_mod() {
    if [[ "$words[2]" == "run" && "$words[CURRENT]" != -* ]]; then
        _arguments '*:filename:_files -g "*.py"'
    else
        _uv "$@"
    fi
}
compdef _uv_run_mod uv

age-edit() {
  local secrets_dir=~/.nix/home-manager/dotfiles/secrets
  local file
  if [[ "$1" = /* ]]; then
    file="$1"
  else
    file="$(pwd)/$1"
  fi
  file="$(realpath "$file")"
  file="${file#$secrets_dir/}"
  (cd "$secrets_dir" && RULES=./secrets.nix agenix -e "$file")
}
