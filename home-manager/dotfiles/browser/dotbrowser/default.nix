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

  apply = browser: toml: ''
    ${dotbrowser} ${browser} apply ${toml} -k || true
  '';
in {
  options = lib.setAttrByPath pathList {
    vivaldi.enable = lib.mkEnableOption "Apply vivaldi.toml via dotbrowser";
    brave.enable = lib.mkEnableOption "Apply brave.toml via dotbrowser";
  };

  config.home.file = lib.mkMerge [
    (lib.mkIf cfg.vivaldi.enable {
      ".config/dotbrowser/vivaldi.toml" = {
        source = ./vivaldi.toml;
        onChange = apply "vivaldi" ./vivaldi.toml;
      };
    })
    (lib.mkIf cfg.brave.enable {
      ".config/dotbrowser/brave.toml" = {
        source = ./brave.toml;
        onChange = apply "brave" ./brave.toml;
      };
    })
  ];
}
