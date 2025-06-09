curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate --no-confirm
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
nix run github:nix-community/home-manager -- switch --impure -b backup --flake "github:kln-os/nix/main#server" --refresh
add-visudo && add-authkey && set-zsh

sudo /nix/var/nix/profiles/default/bin/nix run 'github:numtide/system-manager' -- switch --flake '.'