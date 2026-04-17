# WSL2

## Install Nix

```bash
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
```

## Setup

```bash
NIX_CONFIG="experimental-features = nix-command flakes" nix run github:nix-community/home-manager -- switch --impure -b backup --refresh --flake github:xom11/nix/main#server
```
