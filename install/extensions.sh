#!/bin/bash

# Install gnome-extensions-cli only if not already installed
if ! command -v ~/.local/bin/gext &> /dev/null; then
  pipx install gnome-extensions-cli --system-site-packages
fi

EXTENSIONS=(
  "tactile@lundal.io"
  "just-perfection-desktop@just-perfection"
  "blur-my-shell@aunetx"
  "undecorate@sun.wxg@gmail.com"
  "switcher@landau.fi"
  "run-or-raise@edvard.cz"
  "mousefollowsfocus@matthes.biz"
  "clipboard-history@alexsaveau.dev"
)

for ext in "${EXTENSIONS[@]}"; do
  if ! ~/.local/bin/gext list | grep "$ext" &> /dev/null; then
    echo "Installing extension: $ext"
    ~/.local/bin/gext install "$ext"
  else
    echo "Extension already installed: $ext"
  fi
done
