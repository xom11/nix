# xom11/nix

[![Docs](https://img.shields.io/badge/docs-xom11.github.io%2Fnix-blue)](https://xom11.github.io/nix/)

Reproducible, multi-platform system configuration powered by [Nix Flakes](https://nixos.wiki/wiki/Flakes). One repo manages macOS, NixOS, standalone Linux, WSL, and Windows — from system settings and services down to shell aliases and editor plugins.

## Quick Start

```bash
# One-line install
curl -fsSL https://raw.githubusercontent.com/xom11/nix/main/install | sh

# Or clone manually
git clone https://github.com/xom11/nix.git ~/.nix --depth 1
```

## Supported Platforms

| Platform | Device | Rebuild Command |
|----------|--------|-----------------|
| macOS (nix-darwin) | `macmini`, `airm3` | `sudo darwin-rebuild switch --impure --flake ~/.nix#<device>` |
| NixOS | `x1g6`, `vmware` | `sudo nixos-rebuild switch --impure --flake ~/.nix#<device>` |
| Linux (home-manager) | `rog`, `server`, `desktop`, `a14`, `minimal` | `home-manager switch --impure -b backup --flake ~/.nix#<device>` |
| Linux (system-manager) | `desktop`, `a14` | `sudo nix run 'github:numtide/system-manager' -- switch --flake ~/.nix#<device>` |
| Windows | — | PowerShell scripts + symlinks (no Nix) |

`--impure` is required: `lib/mkConfigs.nix` reads `$USER` and `builtins.currentSystem` at eval time.

## Architecture

```
flake.nix                # Entry point — inputs & outputs
lib/                     # mkDarwin, mkNixos, mkHomeManager, mkSystemManager
hosts/{device}/          # Per-device configuration.nix and/or home.nix
├── macmini/             # Apple Mac Mini (M-series)
├── airm3/               # MacBook Air M3
├── x1g6/                # ThinkPad X1 Carbon Gen 6 (NixOS + i3wm)
├── vmware/              # VMware VM (NixOS, aarch64)
├── rog/                 # ASUS ROG laptop (home-manager)
├── server/              # Headless Linux server
├── desktop/             # Linux desktop (home-manager + system-manager)
├── a14/                 # ASUS ZenBook A14 (Snapdragon ARM — see hosts/a14/README.md)
└── minimal/             # Minimal home-manager profile
nix-darwin/              # macOS system modules
├── base/                #   Nix settings, sudo, garbage collection
├── brew/                #   Homebrew brews + casks (25+ apps)
├── launchd/             #   Launch daemons (kanata)
└── setting/             #   Dock, Finder, trackpad, keyboard, dark mode
home-manager/            # User-level modules (cross-platform)
├── base/                #   User, home dir, env variables (+ macos/, ubuntu/)
├── programs/            #   btop, git, herdr, nvim, ssh, tmux, yazi, zsh
├── dotfiles/            #   Symlinked configs (ai/, browser/, terminal/, macos/, vscode, ...)
├── environments/        #   fonts, gnome, i18n (Vietnamese), i3wm, sway, wayland
├── pkgs/                #   Package groups: dev, lang, tools, nixos, ubuntu
└── services/            #   agenix, syncthing
nixos/                   # NixOS system modules
├── base/                #   Boot, network, locale, users, bluetooth
├── programs/            #   nix-ld
├── services/            #   environments, hibernate, ibus, kanata, keyd
└── systemPackages/      #   Python 3.11-3.13
system-manager/          # Non-NixOS Linux system config (a14, desktop)
├── base/                #   sudoers secure_path
├── etc/trackpad/        #   libinput trackpad tuning
└── services/            #   docker, kanata, keyd, openssh
windows/                 # Windows config (no Nix — PowerShell + symlinks)
├── lib/                 #   Logging, Package, Symlink modules
├── modules/             #   packages/ (winget, scoop, npm, psmodules), services/ (ahk, kanata, sshd)
├── apply.ps1            #   Entry point
└── links.ps1            #   Symlinks the shared dotfiles from home-manager/dotfiles/
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

**Editors** — Neovim via [nixvim](https://github.com/nix-community/nixvim), with the Lua config kept as real files and symlinked in

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
| `nixgl` | OpenGL wrapper for non-NixOS |
| `nix-apt` | Declarative apt packages on Debian/Ubuntu |
| `beckon`, `dotbrowser` | Custom tools, shipped as overlays |

## Documentation

Full documentation: **https://xom11.github.io/nix/**

Guides also available in [`docs/`](docs/):

- [macOS Setup](docs/setup/macos.md)
- [Linux Setup](docs/setup/linux.md)
- [NixOS Setup](docs/setup/nixos.md)
- [WSL Setup](docs/setup/wsl.md)
- [Windows Setup](docs/setup/windows.md)
- [Creating Modules](docs/guides/modules.md)
- [Keyboard Shortcuts](docs/guides/shortcuts.md)

## Troubleshooting

```bash
# Enable flakes if not already configured
mkdir -p ~/.config/nix && echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```
