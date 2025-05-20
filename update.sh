#!/usr/bin/env bash

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    nix run github:nix-community/home-manager -- switch --impure -b backup --flake ~/nix#macos
    sudo darwin-rebuild switch --impure --flake ~/nix#macos
else
    # NixOS
    nix run github:nix-community/home-manager -- switch --impure -b backup --flake ~/nix#nixos
    sudo nixos-rebuild switch --impure --flake ~/nix#nixos
fi