# NixOS

## Rebuild

```bash
sudo nixos-rebuild switch --impure --flake ~/.nix#vm
sudo nixos-rebuild switch --impure --flake ~/.nix#rog
```

## Fresh install (Disko)

Partitions the disk **destructively**, then installs. Run from the NixOS
installer ISO. The per-host script clones the repo to `/tmp/nix` and applies
that host's `disko.nix`:

```bash
# rog — ASUS ROG Strix G531GT
curl -fsSL https://raw.githubusercontent.com/xom11/nix/main/hosts/rog/install.sh | bash

# vm
curl -fsSL https://raw.githubusercontent.com/xom11/nix/main/hosts/vm/install.sh | bash
```

Or, if the repo is already cloned:

```bash
sudo nix --extra-experimental-features 'nix-command flakes' \
  run github:nix-community/disko -- --mode disko ~/.nix/hosts/rog/disko.nix
sudo nixos-install --impure --flake ~/.nix#rog
```
