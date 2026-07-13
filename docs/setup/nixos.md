# NixOS

## Rebuild

```bash
sudo nixos-rebuild switch --impure --flake ~/.nix#x1g6
sudo nixos-rebuild switch --impure --flake ~/.nix#vmware
```

## Fresh install (Disko)

Partitions the disk **destructively**, then installs. Run from the NixOS
installer ISO. The per-host script clones the repo to `/tmp/nix` and applies
that host's `disko.nix`:

```bash
# x1g6 — ThinkPad X1 Carbon Gen 6
curl -fsSL https://raw.githubusercontent.com/xom11/nix/main/hosts/x1g6/install.sh | bash

# vmware
curl -fsSL https://raw.githubusercontent.com/xom11/nix/main/hosts/vmware/install.sh | bash
```

Or, if the repo is already cloned:

```bash
sudo nix --extra-experimental-features 'nix-command flakes' \
  run github:nix-community/disko -- --mode disko ~/.nix/hosts/x1g6/disko.nix
sudo nixos-install --impure --flake ~/.nix#x1g6
```
