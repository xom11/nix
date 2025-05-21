#!/usr/bin/env bash

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sudo darwin-rebuild switch --impure --flake ~/nix#macos
    nix run github:nix-community/home-manager -- switch --impure -b backup --flake ~/nix#macos
else
    # NixOS
    sudo nixos-rebuild switch --impure --flake ~/nix#nixos
    nix run github:nix-community/home-manager -- switch --impure -b backup --flake ~/nix#nixos
fi