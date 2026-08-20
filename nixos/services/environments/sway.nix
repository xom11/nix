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
  # `programs.sway` does the hard part: installs the session .desktop, pulls in
  # the wlr portal, dbus and polkit. This only INSTALLS the session -- something
  # else has to list it at login.
  config = lib.mkIf (cfg.enable && builtins.elem "sway" cfg.types) {
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };
  };
}
