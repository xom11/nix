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
    brave
    discord
    vscode
    bitwarden-desktop
    telegram-desktop
    localsend
    joplin-desktop
    slack
    thunderbird
    google-chrome
    chromedriver
    caprine
  ];
}
