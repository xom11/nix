rsync -a ~/.nix-profile/share/applications/ ~/.local/share/applications 
sudo rsync -a ~/.nix-profile/bin/ /usr/share/bin/
sudo update-desktop-database