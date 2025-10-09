#!/usr/bin/env sh
set -e

git clone https://github.com/kln-os/nix.git ~/.nix -q --depth 1
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
sudo nix run --extra-experimental-features 'nix-command flakes' nix-darwin/master#darwin-rebuild -- switch --impure  --flake ~/.nix#macmini
