#!/usr/bin/env sh
set -e

curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate --no-confirm
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# Single build — symlinks point to Nix store (read-only) but work correctly.
# Activation hook clones ~/.nix for future edits.
nix run github:nix-community/home-manager -- switch --impure -b backup --flake "github:xom11/nix/main#minimal" --refresh