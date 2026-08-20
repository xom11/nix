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
  # Like sway.nix: the nixpkgs option installs the session .desktop and pulls in
  # the portal. The binary comes from here; the home-manager side owns the config.
  # This only INSTALLS the session -- something else has to list it at login.
  config = lib.mkIf (cfg.enable && builtins.elem "hyprland" cfg.types) {
    programs.hyprland.enable = true;

    # Portal arbitration, which nixpkgs does NOT do here: `programs.sway` ships a
    # portals.conf, `programs.hyprland` ships nothing equivalent, and both the
    # hyprland and wlr portals claim UseIn=Hyprland -- so nothing decides between
    # them.
    #
    # Whether it actually picks wrong is unmeasured (that needs a live Hyprland
    # session), but relying on default order is relying on luck. Nothing fails at
    # rebuild time; it would only surface as broken screen sharing or screenshots.
    xdg.portal.config.hyprland = {
      default = "gtk";
      "org.freedesktop.impl.portal.ScreenCast" = "hyprland";
      "org.freedesktop.impl.portal.Screenshot" = "hyprland";
    };
  };
}
