
```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate --no-confirm
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
nix run github:nix-community/home-manager -- switch --impure -b backup --refresh --flake "github:kln-os/nix/main#desktop"
add-visudo && set-zsh
```
```bash
sudo /nix/var/nix/profiles/default/bin/nix run 'github:numtide/system-manager' -- switch --flake '~/nix'
```
