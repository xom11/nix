# How to create modules 
1. Basic
```nix
{config, lib, ...}:
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

2. Advanced
```nix
{config, lib, getRelPath, ...}:
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

3. Function
```nix
{config, mkModule, ...}:
mkModule config ./.
{
}
```

