# Linux

## Install Nix

```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate --no-confirm
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

## Server Setup

```bash
nix run github:nix-community/home-manager -- switch --impure -b backup --refresh --flake github:kln-os/nix/main#server
add-visudo && add-authkey && set-zsh
```

## Desktop Setup

```bash
nix run github:nix-community/home-manager -- switch --impure -b backup --refresh --flake ~/.nix#desktop
add-visudo && add-authkey && set-zsh
```

### System Manager

```bash
sudo /nix/var/nix/profiles/default/bin/nix run 'github:numtide/system-manager' -- switch --flake ~/.nix#desktop
```
