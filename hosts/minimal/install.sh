#!/usr/bin/env sh
set -eu

command -v nix >/dev/null 2>&1 || curl -fsSL https://install.determinate.systems/nix | sh -s -- install --no-confirm
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

nix run github:nix-community/home-manager -- switch --impure -b backup --flake "github:xom11/nix/main#minimal"

sudo chsh -s "/home/$USER/.nix-profile/bin/zsh" "$USER"

if ! sudo grep -qF "$USER ALL=(ALL) NOPASSWD: ALL" /etc/sudoers; then
    echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
    echo "Granted passwordless sudo privileges to current user."
fi

