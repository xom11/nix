{
  config,
  lib,
  pkgs,
  getRelPath,
  ...
}: let
  relPath = getRelPath ./.;
  pathList = ["modules"] ++ lib.splitString "/" relPath;
  cfg = lib.getAttrFromPath pathList config;

  dotbrowser = lib.getExe pkgs.dotbrowser;

  # Activation strips PATH; sudo + dotbrowser need pkill, pgrep, osascript,
  # open, defaults, plutil. Cover macOS (/usr/bin, /usr/sbin) and NixOS
  # (/run/wrappers/bin). Passed to sudo so the child process inherits it.
  systemPath = "/usr/bin:/bin:/usr/sbin:/sbin:/run/wrappers/bin";

  apply = browser: toml:
    lib.hm.dag.entryAfter ["writeBoundary"] ''
      PATH=${systemPath}:$PATH \
        sudo -n PATH=${systemPath}:$PATH ${dotbrowser} ${browser} apply ${toml}\
        || echo "[dotbrowser] ${browser} apply failed — see error above" >&2
    '';
in {
  options = lib.setAttrByPath pathList {
    vivaldi.enable = lib.mkEnableOption "Apply vivaldi.toml via dotbrowser";
    brave.enable = lib.mkEnableOption "Apply brave.toml via dotbrowser";
  };

  config.home.activation = lib.mkMerge [
    (lib.mkIf cfg.vivaldi.enable {
      dotbrowserVivaldi = apply "vivaldi" ./vivaldi.toml;
    })
    (lib.mkIf cfg.brave.enable {
      dotbrowserBrave = apply "brave" ./brave.toml;
    })
  ];
}
