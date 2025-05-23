# nix install
```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```
# add ssh key
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
sudo darwin-rebuild switch --impure --flake ~/nix#macos
```
```bash
sudo nixos-rebuild switch --impure --flake ~/nix#nixos
```
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/nix#macos
