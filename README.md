# Install 
```bash
curl -fsSL https://raw.githubusercontent.com/kln-os/nix/main/install | sh
```
---
# Details
## Linux
### Install Nix
```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate --no-confirm
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```
### Server Setup
```bash
nix run github:nix-community/home-manager -- switch --impure -b backup  --refresh --flake github:kln-os/nix/main#server
add-visudo && add-authkey && set-zsh
```
### Desktop Setup
```bash
nix run github:nix-community/home-manager -- switch --impure -b backup --refresh --flake github:kln-os/nix/main#desktop 
add-visudo && add-authkey && set-zsh
```
### Nixos Setup
```bash
sudo nixos-rebuild switch --impure --refesh --flake github:kln-os/nix/main#x1g6
```
## MacOS
## Install Nix
```bash
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
```
### Macmini Setup
```bash
sudo darwin-rebuild switch --impure --flake ~/nix#macmini
```
### Macair Setup
```bash
sudo nix run --extra-experimental-features 'nix-command flakes' nix-darwin/master#darwin-rebuild -- switch --impure --refresh --flake github:kln-os/nix/main#macair
```
# Other Setup
## SSH Key Generation
```bash
ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519 && cat ~/.ssh/id_ed25519.pub
```