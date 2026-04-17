# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Rebuild Commands

```bash
# macOS (nix-darwin) — also available as shell alias `update`
sudo darwin-rebuild switch --impure --flake ~/.nix#macmini
sudo darwin-rebuild switch --impure --flake ~/.nix#airm3

# NixOS
sudo nixos-rebuild switch --flake ~/.nix#x1g6
sudo nixos-rebuild switch --flake ~/.nix#vmware

# Standalone home-manager (server/desktop)
home-manager switch --flake ~/.nix#server
home-manager switch --flake ~/.nix#desktop
```

`--impure` is required because `lib/mkConfigs.nix` reads `$USER`/`$SUDO_USER` at eval time.

## Architecture

### Flake outputs

`flake.nix` defines outputs via thin wrappers in `lib/mkConfigs.nix`:

| Builder | Outputs |
|---|---|
| `lib.mkDarwin` | `darwinConfigurations.{macmini,airm3}` |
| `lib.mkNixos` | `nixosConfigurations.{x1g6,vmware}` |
| `lib.mkHomeManager` | `homeConfigurations.{server,desktop}` |
| `lib.mkSystemManager` | `systemConfigs.desktop` |

Each builder wires nix-darwin/NixOS/home-manager with `hosts/{device}/configuration.nix` and `hosts/{device}/home.nix`.

### Special args

All modules receive these extra args (defined in `lib/mkConfigs.nix`):

- `device` — string name of the current host
- `username` — detected from `$SUDO_USER`/`$USER` at eval time, falls back to `"kln"`
- `homeDir` — `/Users/$username` on darwin, `/home/$username` on linux
- `repoPath` — resolves to `~/.nix` if it exists, else `../.nix`
- `getPath path` — converts a Nix store path back to its real filesystem path under `repoPath`
- `mkModule`, `ckModule` — module helpers (see below)

### mkModule pattern

Every module in `home-manager/` and `nix-darwin/` uses one of three styles:

```nix
# Style 1 — simple (manual enable option)
{ config, lib, ... }:
let cfg = config.modules.gnome; in
{ options.modules.gnome.enable = lib.mkEnableOption "gnome"; config = lib.mkIf cfg.enable { ... }; }

# Style 2 — advanced (path-derived option with extra options)
{ config, lib, getRelPath, ... }:
let relPath = getRelPath ./.; pathList = ["modules"] ++ lib.splitString "/" relPath;
    cfg = lib.getAttrFromPath pathList config;
in { options = lib.setAttrByPath pathList { enable = ...; screen.dpi = ...; }; config = lib.mkIf cfg.enable { ... }; }

# Style 3 — function shorthand (most common)
{ config, mkModule, ... }:
mkModule config ./. { ... }
```

`mkModule config path content` automatically:
1. Derives the module's option path from its filesystem path (e.g. `home-manager/programs/zsh` → `options.modules.home-manager.programs.zsh.enable`)
2. Wraps `content` under `lib.mkIf cfg.enable`

### Module tree

```
nix-darwin/          # macOS system modules (brew, launchd, settings)
home-manager/
  base/              # username, homeDir, stateVersion, sessionVariables
  programs/          # bin, btop, git, lazyvim, nixvim, ssh, tmux, yazi, zsh
  dotfiles/          # app configs linked via mkOutOfStoreSymlink (aichat, hammerspoon, kitty, vscode, …)
  environments/      # fonts, gnome, i18n, i3wm, wayland
  pkgs/              # dev, test, gui package groups
  services/          # syncthing
nixos/               # NixOS base, programs, services, systemPackages
system-manager/      # alternative system config for non-macOS Linux
overlays/            # custom packages: fcitx5-macos, neofetch2, raiseorlaunch
hosts/{device}/      # per-device configuration.nix + home.nix
configs/             # non-Nix config files: ansible playbooks, kanata layouts
```

### Dotfile linking pattern

Dotfiles are kept as real files in the repo and symlinked at activation time (so edits take effect without rebuilding):

```nix
home.file."${config.xdg.configHome}/zsh/zsh.d" = {
  source = config.lib.file.mkOutOfStoreSymlink "${getPath ./.}/zsh.d";
};
```

### Adding a new module

1. Create `home-manager/<category>/<name>/default.nix` using `mkModule config ./. { ... }`
2. Enable it per-device in `hosts/{device}/home.nix` under `modules.home-manager.<category>.<name>.enable = true`

The module is auto-discovered — no import list to update.

## Git

- Do NOT add `Co-Authored-By` lines to commit messages.

