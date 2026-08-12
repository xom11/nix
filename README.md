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

Per-host commands live in each `hosts/<device>/README.md`.

## Supported Platforms

| Platform | Device | Rebuild Command |
|----------|--------|-----------------|
| macOS (nix-darwin) | `macmini`, `airm3` | `sudo darwin-rebuild switch --impure --flake ~/.nix#<device>` |
| NixOS | `x1g6`, `vm` | `sudo nixos-rebuild switch --impure --flake ~/.nix#<device>` |
| Linux (home-manager) | `rog`, `server`, `desktop`, `minimal` | `home-manager switch --impure -b backup --flake ~/.nix#<device>` |
| Linux (system-manager) | `desktop` | `sudo nix run 'github:numtide/system-manager' -- switch --flake ~/.nix#<device>` |
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
├── vm/                  # VMware Fusion VM (NixOS, aarch64)
├── rog/                 # ASUS ROG laptop (home-manager)
├── server/              # Headless Linux server
├── desktop/             # Linux desktop (home-manager + system-manager)
└── minimal/             # Minimal home-manager profile
nix-darwin/              # macOS system modules
├── base/                #   Nix settings, sudo, garbage collection
├── brew/                #   Homebrew brews + casks (25+ apps)
├── launchd/             #   Launch daemons (kanata)
└── setting/             #   Dock, Finder, trackpad, keyboard, dark mode
home-manager/            # User-level modules (cross-platform)
├── base/                #   User, home dir, env variables (+ macos/, ubuntu/)
├── programs/            #   agenix, btop, git, herdr, nvim, ssh, tmux, yazi, zsh
├── dotfiles/            #   Symlinked configs (ai/, browser/, terminal/, macos/, ...)
├── environments/        #   fonts, gnome, i18n (Vietnamese), i3wm, sway
└── pkgs/                #   Package groups: dev, lang, tools, nixos, ubuntu
nixos/                   # NixOS system modules
├── base/                #   Boot, network, locale, users, bluetooth
├── programs/            #   nix-ld
└── services/            #   environments, kanata
system-manager/          # Non-NixOS Linux system config (desktop)
├── base/                #   sudoers secure_path
├── etc/trackpad/        #   libinput trackpad tuning
└── services/            #   docker, kanata, keyd, openssh
windows/                 # Windows config (no Nix — PowerShell + symlinks)
├── lib/                 #   Logging, Package, Symlink modules
├── modules/             #   packages/ (winget, scoop, npm, psmodules), services/ (ahk, kanata, sshd)
├── apply.ps1            #   Entry point
└── links.ps1            #   Symlinks the shared dotfiles from home-manager/dotfiles/
overlays/                # Local package overlays (currently empty — see ATTIC.md)
configs/                 # Non-Nix configs: kanata keyboards, app shortcuts
scripts/                 # Install & bootstrap scripts
ATTIC.md                 # Code removed from the tree — what, when, how to get it back
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

**Windows** — AutoHotkey v2 (window manager, app launcher, input switcher), PowerShell profile (Oh-My-Posh, PSFzf, posh-git), registry-based system tweaks, dotfiles via PowerShell symlinks — shares Neovim, SSH, Yazi, and Claude configs with the Nix side

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
| [`nix-apt`](https://github.com/xom11/nix-apt) | Declarative apt packages on Debian/Ubuntu |
| [`beckon`](https://github.com/xom11/beckon) | Focus-or-launch app switcher, shipped as an overlay |
| [`dotbrave`](https://github.com/xom11/dotbrave) | Brave as a dotfile (shortcuts, settings, PWAs) — overlay + darwin module |
| [`tongue`](https://github.com/xom11/tongue) | vi/en/zh input-mode switcher, overlay, darwin only |

[`dotpkg`](https://github.com/xom11/dotpkg) is a fifth own tool, wired
differently: it manages winget and scoop, so there is no flake input and no
overlay — a machine without either has nothing for it to manage. Since
2026-08-12 it is the only thing that installs packages on Windows;
`packages.scoop` and `packages.winget` are gone and
`windows/modules/packages/dotpkg` calls `dotpkg apply` in their place.

Two committed files drive it, both under
`home-manager/dotfiles/windows/dotpkg/`: `pkg.toml` declares, and `pkg.lock`
pins — the same role `flake.lock` plays for the nix hosts. Neither is symlinked
into `%USERPROFILE%`: dotpkg rewrites the lock through `fs::rename`, and a
rename replaces a symlink with a regular file, after which the repo silently
stops receiving pins. Run it by hand from that directory, where its own
defaults resolve to those two files.

The last four are own tools kept in their own repos, as is
[`tongue.nvim`](https://github.com/xom11/tongue.nvim) (pinned in
`nvim-pack-lock.json`, not a flake input). A bug in any of them is fixed
upstream, not worked around here — see [`CLAUDE.md`](CLAUDE.md) for how each
one is pinned and how to test an unreleased fix with `--override-input`.

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
