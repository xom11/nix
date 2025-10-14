{config, lib, ...}:
let
  cfg = config.services.desktop-environment;
in
{
  options.services.desktop-environment = {
    enable = lib.mkEnableOption "Enable desktop environment services";
    type = lib.mkOption {
      type = lib.types.enum [ "i3wm" "gnome" "kde" ];
      default = "i3wm";
      description = "Choose your desktop environment";
    };
  };
  
  imports = [
  ./i3wm.nix
  ./gnome.nix
  ./kde.nix
  ];
};
