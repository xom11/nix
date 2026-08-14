#!/usr/bin/env bash
# XOA SACH /dev/nvme0n1 roi cai lai NixOS theo hosts/rog/disko.nix.
# Chay tu NixOS live USB, KHONG chay tren he dang song.
# Sau buoc nay o con ~238G trong o cuoi, danh cho trinh cai Windows.
set -euo pipefail
git clone https://github.com/xom11/nix.git /tmp/nix -q --depth 1
sudo nix --extra-experimental-features 'nix-command flakes' run github:nix-community/disko -- --mode disko /tmp/nix/hosts/rog/disko.nix
sudo nixos-install --impure --flake /tmp/nix#rog
