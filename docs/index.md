# xom11/nix

Personal Nix configurations for macOS, NixOS, and Linux.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/xom11/nix/main/install | sh
```

## Clone

```bash
git clone https://github.com/xom11/nix.git ~/.nix -q --depth 1
```

## Architecture

### Flake Outputs

| Builder | Outputs |
|---|---|
| `lib.mkDarwin` | `darwinConfigurations.{macmini,airm3}` |
| `lib.mkNixos` | `nixosConfigurations.{x1g6,vmware}` |
| `lib.mkHomeManager` | `homeConfigurations.{server,desktop}` |
| `lib.mkSystemManager` | `systemConfigs.desktop` |

Each builder wires nix-darwin/NixOS/home-manager with `hosts/{device}/configuration.nix` and `hosts/{device}/home.nix`.

### Module Tree

```
nix-darwin/          # macOS system modules (brew, launchd, settings)
home-manager/
  base/              # username, homeDir, stateVersion, sessionVariables
  programs/          # bin, btop, git, lazyvim, nixvim, ssh, tmux, yazi, zsh
  dotfiles/          # app configs linked via mkOutOfStoreSymlink
  environments/      # fonts, gnome, i18n, i3wm, wayland
  pkgs/              # dev, test, gui package groups
  services/          # syncthing
nixos/               # NixOS base, programs, services, systemPackages
system-manager/      # alternative system config for non-macOS Linux
overlays/            # custom packages
hosts/{device}/      # per-device configuration.nix + home.nix
configs/             # non-Nix config files: ansible playbooks, kanata layouts
```

## Troubleshooting

If you get experimental features errors:

```bash
mkdir -p ~/.config/nix && echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```
