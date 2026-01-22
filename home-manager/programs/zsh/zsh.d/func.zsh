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

install_pwa() {
  local apps=(
    "https://web.telegram.org"
    "https://discord.com/app"
    "https://www.youtube.com"
    "https://gemini.google.com"
    "https://www.messenger.com"
    "https://keep.google.com"
    "https://www.notion.so/"
  )

  if [[ "$OSTYPE" == "darwin"* ]]; then
    open -a "Brave Browser" "${apps[@]}"
  else
    brave-browser "${apps[@]}" &>/dev/null &
  fi
}
