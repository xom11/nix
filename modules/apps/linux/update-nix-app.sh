sudo rsync -a ~/.nix-profile/bin/ /usr/share/bin/
sudo mkdir -p /usr/share/icons/nix/
sudo rsync -a ~/.nix-profile/share/applications/ /usr/share/applications/
sudo rsync -a ~/.nix-profile/share/icons/ /usr/share/icons/nix/
sudo update-desktop-database