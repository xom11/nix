# Linux

## Install Nix

```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate --no-confirm
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

## Bootstrap

Passwordless sudo + zsh as the login shell. Run once, after the first switch
below. `usermod`, not `chsh`: chsh authenticates through PAM and fails
non-interactively.

```bash
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/"$USER" > /dev/null && sudo chmod 440 /etc/sudoers.d/"$USER"
sudo usermod -s "$HOME/.nix-profile/bin/zsh" "$USER"
```

`authorized_keys` is installed by the `programs.ssh` module during activation —
nothing to do by hand.

## Server Setup

```bash
nix run github:nix-community/home-manager -- switch --impure -b backup --refresh --flake github:xom11/nix/main#server
```

Or just `curl -fsSL https://raw.githubusercontent.com/xom11/nix/main/install | sh`,
which does the Nix install, the switch and the bootstrap above in one go.

## Desktop Setup

```bash
nix run github:nix-community/home-manager -- switch --impure -b backup --refresh --flake ~/.nix#desktop
```

### System Manager

```bash
sudo /nix/var/nix/profiles/default/bin/nix run 'github:numtide/system-manager' -- switch --flake ~/.nix#desktop
```
