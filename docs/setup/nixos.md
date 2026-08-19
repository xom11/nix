# NixOS

## Rebuild

```bash
sudo nixos-rebuild switch --impure --flake ~/.nix#vm
sudo nixos-rebuild switch --impure --flake ~/.nix#rog
```

## Fresh install (Disko)

Partitions the disk **destructively**, then installs. Run from the NixOS
installer ISO. The script clones the repo to `/tmp/nix`, applies that host's
`disko.nix`, then runs `nixos-install`.

**The two hosts name that script differently.** On `rog` it is `disko.sh`; on
`vm` it is `install.sh`. `rog/install.sh` is the *other* thing entirely — clone
to `~/.nix` and `nixos-rebuild switch` on a system that is already installed
(that one is `vm/setup.sh` on the VM). Read the script before piping it to a
shell.

```bash
# rog — ASUS ROG Strix G531GT
curl -fsSL https://raw.githubusercontent.com/xom11/nix/main/hosts/rog/disko.sh | bash

# vm
curl -fsSL https://raw.githubusercontent.com/xom11/nix/main/hosts/vm/install.sh | bash
```

Or, if the repo is already cloned:

```bash
sudo nix --extra-experimental-features 'nix-command flakes' \
  run github:nix-community/disko -- --mode disko ~/.nix/hosts/rog/disko.nix
sudo nixos-install --impure --flake ~/.nix#rog
```
