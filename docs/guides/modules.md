# Create Modules

## Style 1 — Basic

Manual enable option:

```nix
{ config, lib, ... }:
let
  cfg = config.modules.gnome;
in
{
  options.modules.gnome = {
    enable = lib.mkEnableOption "Enable gnome settings";
  };
  config = lib.mkIf cfg.enable {
  };
}
```

## Style 2 — Advanced

Path-derived option with extra options:

```nix
{ config, lib, getRelPath, ... }:
let
  relPath = getRelPath ./.;
  pathList = ["modules"] ++ (lib.splitString "/" relPath);
  cfg = lib.getAttrFromPath pathList config;
in
{
  options = lib.setAttrByPath pathList {
    enable = lib.mkEnableOption "Enable x11 settings";
    screen.dpi = lib.mkOption {
      type = lib.types.int;
      default = 144;
      description = "Set screen DPI [96, 144, 192]";
    };
  };
  config = lib.mkIf cfg.enable {
  };
}
```

## Style 3 — Function Shorthand (Most Common)

```nix
{ config, mkModule, ... }:
mkModule config ./.
{
}
```

`mkModule config path content` automatically:

1. Derives the module's option path from its filesystem path
    - e.g. `home-manager/programs/zsh` → `options.modules.home-manager.programs.zsh.enable`
2. Wraps `content` under `lib.mkIf cfg.enable`

## Adding a New Module

1. Create `home-manager/<category>/<name>/default.nix` using `mkModule config ./. { ... }`
2. Enable it per-device in `hosts/{device}/home.nix` under `modules.home-manager.<category>.<name>.enable = true`

The module is auto-discovered — no import list to update.
