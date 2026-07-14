# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Rebuild Commands

`--impure` is required everywhere: `lib/mkConfigs.nix` reads `$USER`/`$SUDO_USER`
and `builtins.currentSystem` at eval time.

```bash
# macOS (nix-darwin) — also available as shell alias `update`
sudo darwin-rebuild switch --impure --flake ~/.nix#macmini
sudo darwin-rebuild switch --impure --flake ~/.nix#airm3

# NixOS
sudo nixos-rebuild switch --impure --flake ~/.nix#x1g6
sudo nixos-rebuild switch --impure --flake ~/.nix#vmware

# Standalone home-manager
home-manager switch --impure -b backup --flake ~/.nix#server     # also: rog, desktop, a14, minimal

# system-manager (system-level config on a non-NixOS Linux distro)
sudo nix run 'github:numtide/system-manager' -- switch --flake ~/.nix#a14   # also: desktop
```

## Checking a host without rebuilding it

`--system` overrides `builtins.currentSystem`, so any host can be evaluated from
any machine. This is what CI does (`.github/workflows/eval.yml`), and it is the
fastest way to know whether a change breaks a host you are not sitting at:

```bash
nix eval --impure --system x86_64-linux  .#homeConfigurations.desktop.activationPackage.drvPath
nix eval --impure --system aarch64-linux .#nixosConfigurations.vmware.config.system.build.toplevel.drvPath
nix eval --impure                        .#darwinConfigurations.macmini.system.drvPath
```

`nix flake check` does **not** work here — it evaluates purely and dies on
`builtins.currentSystem`. Use the per-host `nix eval --impure` above instead.

`nix fmt` (alejandra) and `nix develop` (alejandra, nixd, deadnix, statix) are wired up.

## Architecture

### Flake outputs

`flake.nix` defines outputs via thin wrappers in `lib/mkConfigs.nix`:

| Builder | Outputs |
|---|---|
| `lib.mkDarwin` | `darwinConfigurations.{macmini,airm3}` |
| `lib.mkNixos` | `nixosConfigurations.{x1g6,vmware}` |
| `lib.mkHomeManager` | `homeConfigurations.{rog,server,desktop,a14,minimal}` |
| `lib.mkSystemManager` | `systemConfigs.<system>.{desktop,a14}` — keyed by system (`aarch64-linux`, `x86_64-linux`) |

`mkDarwin`/`mkNixos` wire home-manager in as a module (`useGlobalPkgs = true`, so
home-manager reuses the system `pkgs` rather than instantiating nixpkgs twice).
`mkHomeManager` builds its own `pkgs`. All four apply the same overlay list
(`allOverlays` = `overlays/` + the overlays shipped by flake inputs), so
`pkgs.<tool>` resolves identically under every builder.

Each builder wires `hosts/{device}/configuration.nix` and/or `hosts/{device}/home.nix`.
Standalone home-manager hosts have only `home.nix`.

### Special args

All modules receive these extra args (defined in `lib/mkConfigs.nix`):

- `device` — string name of the current host
- `username` — detected from `$SUDO_USER`/`$USER` at eval time, falls back to `"kln"`
- `homeDir` — `/Users/$username` on darwin, `/home/$username` on linux
- `repoPath` — always `$homeDir/.nix`; every `mkOutOfStoreSymlink` points here, so
  it must be a writable working tree (`home-manager/base` clones it on first switch)
- `getRelPath path` — the module's path relative to the repo root
- `getPath path` — converts a Nix store path back to its real filesystem path under `repoPath`
- `autoImport dir` — every nested `default.nix` under `dir`, except `dir`'s own
- `mkModule`, `ckModule` — module helpers (see below)
- plus every flake input, by name

`mkSystemManager` deliberately passes a **reduced** set (`device`, `system`,
`autoImport`, `mkModule`, `ckModule`) — splatting `inputs` there would shadow
system-manager's own `_module.args.system-manager` with the flake input of the
same name.

### Profiles

`profiles/` holds the module sets shared across hosts, so the common toolkit is
defined once rather than copied into every `hosts/*/home.nix` (that copying is
what let three hosts silently rot). A host imports the profiles it wants:

```nix
imports = [ ../../home-manager ../../profiles/core.nix ../../profiles/linux-gui.nix ];
```

| Profile | Contents | Used by |
|---|---|---|
| `core.nix` | zsh, git, nvim, tmux, herdr, yazi, ssh, btop, pkgs.{dev,lang,tools} | every host except `minimal` |
| `linux-gui.nix` | fonts, i18n, rofi, terminal.kitty — **no window manager** | a14, desktop, x1g6, vmware |
| `macos.nix` | base.macos, fonts, kitty, conda, vscode, hammerspoon, sleepwatcher | macmini, airm3 |

Profiles enable with `lib.mkDefault`, so a host **opts out visibly** instead of
by omission:

```nix
modules.home-manager.programs.git.enable = false;   # hosts/vmware
```

They live at the repo root on purpose. Anything under `home-manager/` is
auto-imported into every host, which would make a profile unconditional rather
than opt-in.

When changing a profile, confirm the hosts you did not intend to touch are
unaffected — `drvPath` should be byte-identical for a pure refactor:

```bash
nix eval --impure --raw .#homeConfigurations.<host>.activationPackage.drvPath
```

### mkModule pattern

Every module in `home-manager/`, `nixos/`, `nix-darwin/` and `system-manager/`
uses one of three styles. Style 3 is by far the most common (~52 modules); style 2
exists only because `mkModule` cannot declare options beyond `enable` (~4 modules,
all under `nixos/services/environments/`); style 1 is a single leftover.

```nix
# Style 1 — manual enable option
{ config, lib, ... }:
let cfg = config.modules.gnome; in
{ options.modules.gnome.enable = lib.mkEnableOption "gnome"; config = lib.mkIf cfg.enable { ... }; }

# Style 2 — path-derived option path, plus extra options
{ config, lib, getRelPath, ... }:
let relPath = getRelPath ./.; pathList = ["modules"] ++ lib.splitString "/" relPath;
    cfg = lib.getAttrFromPath pathList config;
in { options = lib.setAttrByPath pathList { enable = ...; type = ...; }; config = lib.mkIf cfg.enable { ... }; }

# Style 3 — function shorthand (use this)
{ config, mkModule, ... }:
mkModule config ./. { ... }
```

`mkModule config path content`:
1. Derives the option path from the module's filesystem path
2. Declares `enable` there
3. Wraps `content` in `lib.mkIf cfg.enable`

**The option path mirrors the directory path exactly, including intermediate
directories.** This is the single most common source of broken host files:

| Module directory | Option path |
|---|---|
| `home-manager/programs/zsh` | `modules.home-manager.programs.zsh.enable` |
| `home-manager/dotfiles/terminal/kitty` | `modules.home-manager.dotfiles.terminal.kitty.enable` — **not** `dotfiles.kitty` |
| `home-manager/dotfiles/browser/qutebrowser` | `modules.home-manager.dotfiles.browser.qutebrowser.enable` |
| `home-manager/dotfiles/ai/claude.d` | `modules.home-manager.dotfiles.ai."claude.d".enable` — the dot must be quoted |
| `nixos/services/keyd` | `modules.nixos.services.keyd.enable` — **not** `modules.services.keyd` |

Before writing an `enable = true` into a host, confirm the directory exists.
`find home-manager nixos nix-darwin system-manager -name default.nix` is the source of truth.

### Module tree

```
nix-darwin/          # macOS system: base, brew, launchd/kanata, setting
nixos/               # NixOS system: base, programs, systemPackages,
                     #   services/{environments,hibernate,ibus,kanata,keyd}
system-manager/      # system-level config on non-NixOS Linux (a14, desktop):
                     #   base, etc/trackpad, services/{docker,kanata,keyd,openssh}
profiles/            # shared module sets: core, linux-gui, macos (see below)
home-manager/
  base/              # username, homeDir, stateVersion, sessionVariables
                     #   + macos/, ubuntu/, nixos/ — each carries that platform's `update` alias
  programs/          # btop, git, herdr, nvim, ssh, tmux, yazi, zsh
                     #   herdr: config only -- the binary is installed out-of-band,
                     #   pkgs.herdr does not build on darwin (zig/DarwinSdkNotFound)
  dotfiles/          # ai/{aichat.d,claude.d,codex.d,gemini.d,opencode.d}
                     # browser/{firefox,qutebrowser}, terminal/{alacritty,kitty}
                     # macos/{aerospace,hammerspoon,karabiner,sleepwatcher}
                     # conda, rofi, run-or-raise, vscode
  environments/      # fonts, gnome, i18n, i3wm, sway, wayland
  pkgs/              # dev, lang, nixos, tools, ubuntu
  services/          # agenix, syncthing
overlays/            # local packages: fcitx5-macos, neofetch2, raiseorlaunch
hosts/{device}/      # per-device configuration.nix and/or home.nix
configs/             # non-Nix: ansible playbooks, kanata layouts
windows/             # live parallel PowerShell config; reuses the shared dotfiles
                     #   under home-manager/dotfiles via links.ps1. Not orphaned.
```

Modules are auto-discovered — `home-manager/default.nix` (and the equivalent in
`nixos/`, `nix-darwin/`, `system-manager/`) is just `imports = autoImport ./.`,
which pulls in every nested `default.nix`. There is no import list to update, but
note the corollary: a module nobody enables still has its options declared on
every rebuild. That is cheap (the body sits behind `mkIf cfg.enable`), so keeping
an unused module around for reference is fine — but a **broken** one is a landmine,
since enabling it is all it takes to break eval.

### Dotfile linking pattern

Dotfiles are kept as real files in the repo and symlinked at activation time (so
edits take effect without rebuilding):

```nix
home.file."${config.xdg.configHome}/zsh/zsh.d" = {
  source = config.lib.file.mkOutOfStoreSymlink "${getPath ./.}/zsh.d";
};
```

The symlink target is a plain string, so it is **not** a reference of the
home-manager generation. It must point into the `~/.nix` working tree — never into
the store, or the dotfiles are read-only and get collected on the next GC.

### Adding a new module

1. Create `home-manager/<category>/<name>/default.nix` using `mkModule config ./. { ... }`
2. Enable it — in `profiles/core.nix` if every host should get it, otherwise
   per-device in `hosts/{device}/home.nix` under
   `modules.home-manager.<category>.<name>.enable = true`
3. Confirm the hosts you touched still evaluate (see "Checking a host" above)

## Git

- Do NOT add `Co-Authored-By` lines to commit messages.
