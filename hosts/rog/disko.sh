#!/usr/bin/env bash
# WIPES /dev/nvme0n1 and reinstalls NixOS per hosts/rog/disko.nix.
# Run from a NixOS live USB, NEVER on a running system.
# Takes the WHOLE disk: ESP 1G + root ~459.9G + swap 16G. (An older note here
# reserved ~238G for a Windows installer; dual-boot was dropped.)
set -euo pipefail
git clone https://github.com/xom11/nix.git /tmp/nix -q --depth 1
sudo nix --extra-experimental-features 'nix-command flakes' run github:nix-community/disko -- --mode disko /tmp/nix/hosts/rog/disko.nix
sudo nixos-install --impure --flake /tmp/nix#rog
