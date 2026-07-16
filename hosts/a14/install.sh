curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate --no-confirm
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
nix run github:nix-community/home-manager -- switch --impure -b backup --flake "github:xom11/nix/main#a14" --refresh
# Passwordless sudo (drop-in, not editing /etc/sudoers) so the sudo commands
# below don't prompt. This first sudo asks for the password once.
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER > /dev/null && sudo chmod 440 /etc/sudoers.d/$USER
# Login shell -> zsh. usermod, not `chsh -s $(which zsh)`: chsh authenticates
# through PAM and fails non-interactively, and `which zsh` is empty before the
# nix profile is on PATH. usermod writes /etc/passwd directly with the real path.
sudo usermod -s "$HOME/.nix-profile/bin/zsh" "$USER"
# kanata (+ tailscale) run as system-manager system services; this sets up
# /dev/uinput permissions declaratively, so no manual group/udev setup is needed.
sudo nix run 'github:numtide/system-manager' -- switch --flake "github:xom11/nix/main#a14"

