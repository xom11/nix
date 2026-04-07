# kln-os/nix

Reproducible, multi-platform system configuration powered by [Nix Flakes](https://nixos.wiki/wiki/Flakes). One repo manages macOS, NixOS, standalone Linux, WSL, and Windows — from system settings and services down to shell aliases and editor plugins.

## Quick Start

```bash
# One-line install
curl -fsSL https://raw.githubusercontent.com/kln-os/nix/main/install | sh

# Or clone manually
git clone https://github.com/kln-os/nix.git ~/.nix --depth 1
```

## Supported Platforms

| Platform | Device | Rebuild Command |
|----------|--------|-----------------|
| macOS (nix-darwin) | `macmini`, `airm3` | `sudo darwin-rebuild switch --impure --flake ~/.nix#<device>` |
| NixOS | `x1g6`, `vmware` | `sudo nixos-rebuild switch --flake ~/.nix#<device>` |
| Linux (home-manager) | `server`, `desktop` | `home-manager switch --flake ~/.nix#<device>` |
| Linux (system-manager) | `desktop` | `sudo nix run 'github:numtide/system-manager' -- switch --flake ~/.nix#desktop` |
| Windows | — | PowerShell scripts + symlinks (no Nix) |

## Architecture

```
flake.nix                # Entry point — inputs & outputs
lib/                     # mkDarwin, mkNixos, mkHomeManager, mkSystemManager
hosts/{device}/          # Per-device configuration.nix + home.nix
├── macmini/             # Apple Mac Mini (M-series)
├── airm3/               # MacBook Air M3
├── x1g6/                # ThinkPad X1 Carbon Gen 6 (NixOS + i3wm)
├── vmware/              # VMware VM (NixOS)
├── server/              # Headless Linux server
├── desktop/             # Linux desktop (home-manager + system-manager)
└── zenbook-a14/         # ASUS ZenBook A14 (Snapdragon ARM — requires manual fixes)
nix-darwin/              # macOS system modules
├── base/                #   Nix settings, sudo, garbage collection
├── brew/                #   Homebrew brews + casks (25+ apps)
├── launchd/             #   Launch daemons (kanata)
└── setting/             #   Dock, Finder, trackpad, keyboard, dark mode
home-manager/            # User-level modules (cross-platform)
├── base/                #   User, home dir, env variables
├── programs/            #   zsh, git, tmux, nixvim, lazyvim, yazi, ssh, btop
├── dotfiles/            #   Symlinked configs (kitty, vscode, karabiner, ...)
├── environments/        #   fonts, i3wm, i18n (Vietnamese), wayland
├── pkgs/                #   Package groups: dev, gui, test
└── services/            #   syncthing
nixos/                   # NixOS system modules
├── base/                #   Boot, network, locale, users, bluetooth
├── programs/            #   nix-ld
├── services/            #   Docker, Tailscale, OpenSSH
└── systemPackages/      #   Python 3.10-3.13
system-manager/          # Non-NixOS Linux system config (kanata, sudoers)
windows/                 # Windows config (no Nix — PowerShell + symlinks)
├── ahk/                 #   AutoHotkey v2: window manager, app launcher, kanata, input switcher
├── dotfiles/            #   PowerShell profile, Windows Terminal, PowerToys + symlink script
└── scripts/             #   System tweaks (registry), debloat, startup services
overlays/                # Custom packages (fcitx5-macos, neofetch2, raiseorlaunch)
configs/                 # Non-Nix configs: kanata keyboards, Ansible playbooks
scripts/                 # Install & bootstrap scripts
```

## Module System

Modules are auto-discovered from the filesystem — no import lists to maintain. Each module uses the `mkModule` helper:

```nix
# home-manager/programs/zsh/default.nix
{ config, mkModule, ... }:
mkModule config ./. {
  # module content
}
```

This automatically creates an enable option derived from the file path (`modules.home-manager.programs.zsh.enable`) and wraps the content in `mkIf cfg.enable`.

Enable modules per-device in `hosts/{device}/home.nix`:

```nix
modules.home-manager = {
  programs = {
    zsh.enable = true;
    git.enable = true;
    tmux.enable = true;
  };
  pkgs.dev.enable = true;
};
```

## Key Features

**Terminal** — Zsh + Oh-My-Zsh + Powerlevel10k, Tmux with session persistence, Yazi file manager, 75+ aliases

**Editors** — Three Neovim configs (nixvim, lazyvim, nvimpack) sharing keymaps and plugins

**Keyboard** — [Kanata](https://github.com/jtroo/kanata) remapper on all platforms (macOS, NixOS, Ubuntu, Windows)

**Dev Tools** — Rust, Python (uv + micromamba), Node.js (bun), Go, .NET, Docker/Podman, Ansible

**macOS** — Dock/Finder/trackpad tuning, Homebrew integration, Hammerspoon automation, Karabiner

**Desktop Linux** — i3wm + picom + rofi + dunst, Vietnamese input (fcitx5/ibus-bamboo)

**Windows** — AutoHotkey v2 (window manager, app launcher, input switcher), PowerShell profile (Oh-My-Posh, PSFzf, posh-git), registry-based system tweaks, dotfiles via PowerShell symlinks — shares Neovim, VSCode, SSH, Yazi, and Claude configs with the Nix side

**Dotfiles** — Symlinked via `mkOutOfStoreSymlink` (Nix) or PowerShell `New-Item -SymbolicLink` (Windows) — edit in repo, changes apply instantly without rebuild

**Secrets** — [agenix](https://github.com/ryantm/agenix) for encrypted configuration

## Flake Inputs

| Input | Purpose |
|-------|---------|
| `nixpkgs` (unstable) | Package repository |
| `nix-darwin` | macOS system management |
| `home-manager` | User environment management |
| `nix-homebrew` | Declarative Homebrew |
| `nixvim` | Neovim configuration via Nix |
| `nixos-hardware` | Hardware-specific NixOS configs |
| `disko` | Declarative disk partitioning |
| `agenix` | Secrets management |
| `system-manager` | System config for non-NixOS Linux |
| `nix-flatpak` | Declarative Flatpak |
| `ibus-bamboo` | Vietnamese input method |
| `nixgl` | OpenGL wrapper for non-NixOS |

## Documentation

Detailed guides are available in [`docs/`](docs/):

- [macOS Setup](docs/setup/macos.md)
- [Linux Setup](docs/setup/linux.md)
- [NixOS Setup](docs/setup/nixos.md)
- [WSL Setup](docs/setup/wsl.md)
- [Windows Setup](windows/install.md)
- [Creating Modules](docs/guides/modules.md)
- [Keyboard Shortcuts](docs/guides/shortcuts.md)

## Troubleshooting

```bash
# Enable flakes if not already configured
mkdir -p ~/.config/nix && echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```
