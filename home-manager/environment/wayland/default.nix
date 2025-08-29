{lib, config, pkgs, ...}:
let
  cfg = config.modules.wayland;
in
{
  options.modules.wayland = {
    enable = lib.mkEnableOption "Enable Wayland environment";
  };
  config = lib.mkIf cfg.enable {
  };
}