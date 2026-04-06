# macOS

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
sudo nix run --extra-experimental-features 'nix-command flakes' nix-darwin/master#darwin-rebuild -- switch --impure --flake ~/.nix#macmini
```

## Post-install

### Tailscale

```bash
sudo brew services start tailscale
sudo tailscale up
```
