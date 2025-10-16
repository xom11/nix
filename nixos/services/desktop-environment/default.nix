{config, lib, ...}:
let
  inherit (builtins) filter map toString;
  inherit (lib.filesystem) listFilesRecursive;
  inherit (lib.strings) hasSuffix;
in
{
  imports = filter (hasSuffix ".nix") (
    map toString (filter (p: p != ./default.nix) (listFilesRecursive ./.))
  );
  options.modules.services.desktop-environment = {
    enable = lib.mkEnableOption "Enable desktop environment services";
    type = lib.mkOption {
      type = lib.types.enum [ "i3wm" "gnome" "kde" ];
      default = "i3wm";
      description = "Choose your desktop environment";
    };
  };
  
}
