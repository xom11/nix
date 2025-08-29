# Install 
```bash
curl -fsSL https://raw.githubusercontent.com/kln-os/nix/main/install | sh
```
---
# Git Clone
```bash
git clone https://github.com/kln-os/nix.git ~/.nix -q --depth 1
```
---
# Linux
## Install Nix
```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate --no-confirm
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```
## Server Setup
```bash
nix run github:nix-community/home-manager -- switch --impure -b backup  --refresh --flake github:kln-os/nix/main#server
add-visudo && add-authkey && set-zsh
```
---
# Nixos
```bash
sudo nixos-rebuild switch --impure --refesh --flake ~/.nix#x1g6
```
```bash
sudo nixos-rebuild switch --impure --refesh --flake ~/.nix#x1g6
```
---
# MacOS
## Install Nix
```bash
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
```
## Macmini Setup
```bash
sudo darwin-rebuild switch --impure --flake ~/.nix#macmini
```
## Macbook Setup
```bash
sudo nix run --extra-experimental-features 'nix-command flakes' nix-darwin/master#darwin-rebuild -- switch --impure --refresh --flake github:kln-os/nix/main#macbook
```
---
# System Management
## Install Nix 
```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate --no-confirm
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```
## Desktop Setup
```bash
nix run github:nix-community/home-manager -- switch --impure -b backup --refresh --flake ~/.nix\#desktop 
add-visudo && add-authkey && set-zsh
```
```bash
sudo /nix/var/nix/profiles/default/bin/nix run 'github:numtide/system-manager' -- switch --flake ~/.nix\#desktop
---
# Disko Setup
```bash
git clone https://github.com/kln-os/nix.git /tmp/nix -q --depth 1 
sudo nix --extra-experimental-features 'nix-command flakes' run github:nix-community/disko -- --mode disko /tmp/nix/disko/disko-config.nix
nixos-generate-config --no-filesystems
nixos-install --flake --impure  ./nix#kln
nixos-rebuild switch --impure --flake /tmp/nix#kln
```
