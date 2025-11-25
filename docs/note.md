# Old version create module
```nix
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
