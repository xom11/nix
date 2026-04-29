if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
  alias copy='wl-copy'
else
  alias copy='xclip -selection clipboard'
fi
