{ config, lib, pkgs, nixgl, ... }:

{
  imports = [
    ../share
  ];
  nixGL.packages = import nixgl { inherit pkgs; };
  # nixGL.defaultWrapper = "mesa";
  # nixGL.installScripts = [ "mesa" ];

  home.packages = with pkgs; [
    (config.lib.nixGL.wrap kitty)
    telegram-desktop
    localsend
    ####
    brave
    discord
    vscode
    bitwarden-desktop
    joplin-desktop
    slack
    google-chrome
    chromedriver
    caprine
  ];
}
