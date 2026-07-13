#!/usr/bin/env sh
set -eu
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate --no-confirm
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
nix run github:nix-community/home-manager -- switch --impure -b backup --flake "github:xom11/nix/main#server" --refresh
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/"$USER" > /dev/null && sudo chmod 440 /etc/sudoers.d/"$USER"
sudo usermod -s "$HOME/.nix-profile/bin/zsh" "$USER"
