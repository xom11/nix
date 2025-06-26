{ config, lib, pkgs, nixgl, ... }:

{
  nixGL.packages = import nixgl { inherit pkgs; };
  nixGL.defaultWrapper = "mesa";
  nixGL.installScripts = [ "mesa" ];

  targets.genericLinux.enable = true;
  xdg.mime.enable = true;
  xdg.systemDirs.data = [ "${config.home.homeDirectory}/.nix-profile/share/applications" ];

  home.packages = with pkgs; [
    (config.lib.nixGL.wrap kitty)
    # (config.lib.nixGL.wrap brave)
    # (config.lib.nixGL.wrap vscode)
    preload
    bitwarden-desktop
    discord
    vscode
    telegram-desktop
    localsend
    joplin-desktop
    slack
    thunderbird
    google-chrome
    # chromedriver
    caprine

  ];
}