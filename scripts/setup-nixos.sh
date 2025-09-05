git clone https://github.com/kln-os/nix.git /tmp/nix -q --depth 1 
sudo nix --extra-experimental-features 'nix-command flakes' run github:nix-community/disko -- --mode disko /tmp/nix/nixos/disko/default.nix
nixos-generate-config --no-filesystems
nixos-install --flake --impure  ./nix#kln
