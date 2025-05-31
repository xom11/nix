sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --no-daemon --yes
. ~/.nix-profile/etc/profile.d/nix.sh
export NIX_CONFIG="extra-experimental-features = nix-command flakes"
export NIXPKGS_ALLOW_UNFREE=1
nix run github:nix-community/home-manager -- switch --impure --flake "github:kln-os/nix/main#local" --refresh