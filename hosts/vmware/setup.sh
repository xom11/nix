git clone https://github.com/kln-os/nix.git ~/.nix -q --depth 1
sudo nixos-rebuild switch --impure --flake ~/.nix#vmware