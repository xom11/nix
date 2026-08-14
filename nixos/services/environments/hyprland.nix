{
  config,
  lib,
  getRelPath,
  ...
}: let
  relPath = getRelPath ./.;
  pathList = ["modules"] ++ (lib.splitString "/" relPath);
  cfg = lib.getAttrFromPath pathList config;
in {
  # Tuong tu sway.nix: option cua nixpkgs tu cai session .desktop va keo
  # xdg-desktop-portal-hyprland. Binary hyprland den tu day, nen module
  # home-manager ben kia chi lo config.
  config = lib.mkIf (cfg.enable && builtins.elem "hyprland" cfg.types) {
    programs.hyprland.enable = true;
  };
}
