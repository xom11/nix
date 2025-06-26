# Server Setup
```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate --no-confirm
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
nix run github:nix-community/home-manager -- switch --impure -b backup  --refresh --flake "github:kln-os/nix/main#server"
add-visudo && add-authkey && set-zsh
```
# Local Setup
```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate --no-confirm
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
nix run github:nix-community/home-manager -- switch --impure -b backup --refresh --flake "github:kln-os/nix/main#desktop" 
add-visudo && add-authkey && set-zsh
```
# MacOS Setup
```bash
sudo darwin-rebuild switch --impure --flake ~/nix#macos
```
# Nixos Setup
```bash
sudo nixos-rebuild switch --impure --flake github:kln-os/nix/main#x1g6
```


```bash
ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub
```
# install repo
```bash
git clone git@github.com:kln-os/nix.git ~/nix -q
```
# install home-manager
```bash
export NIX_CONFIG="extra-experimental-features = nix-command flakes"
export NIXPKGS_ALLOW_UNFREE=1
nix run github:nix-community/home-manager -- switch --impure --flake ~/nix#server -b bckp
```
```bash
nix run github:nix-community/home-manager -- switch --impure --flake "github:kln-os/nix/main#server" --refresh
nix run github:nix-community/home-manager -- switch --impure --flake "github:kln-os/nix/main#local" --refresh
```

