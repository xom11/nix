{
  config,
  lib,
  getRelPath,
  ...
}: let
  inherit (builtins) filter map toString;
  inherit (lib.filesystem) listFilesRecursive;
  inherit (lib.strings) hasSuffix;
  relPath = getRelPath ./.;
  pathList = ["modules"] ++ (lib.splitString "/" relPath);
in {
  imports = filter (hasSuffix ".nix") (
    map toString (filter (p: p != ./default.nix) (listFilesRecursive ./.))
  );
  options = lib.setAttrByPath pathList {
    enable = lib.mkEnableOption "Enable desktop environment services";
    type = lib.mkOption {
      type = lib.types.enum ["i3wm" "gnome" "kde"];
      default = "i3wm";
      description = "Choose your desktop environment";
    };
  };
}
