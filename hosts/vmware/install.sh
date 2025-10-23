git clone https://github.com/kln-os/nix.git /tmp/nix -q --depth 1 
sudo nix --extra-experimental-features 'nix-command flakes' run github:nix-community/disko -- --mode disko /tmp/nix/host/x1g6/disko.nix
sudo nixos-install --impure --flake /tmp/nix#x1g6

