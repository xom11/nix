if [[ "$NIX_DEVICE" == "macmini" ]]; then
sudo darwin-rebuild switch --impure --flake ~/nix#$NIX_DEVICE
elif [[ "$NIX_DEVICE" == "x1g6" ]]; then
sudo nixos-rebuild switch --impure --flake ~/nix#$NIX_DEVICE
elif [[ "$NIX_DEVICE" == "server" ]]; then
nix run github:nix-community/home-manager -- switch --impure -b backup --flake "github:kln-os/nix/main#$NIX_DEVICE" --refresh
else
echo "Unknown NIX_DEVICE: $NIX_DEVICE"
fi