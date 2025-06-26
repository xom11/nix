{ config, lib, pkgs, nixgl, ... }:

{
  nixGL.packages = import nixgl { inherit pkgs; };
  nixGL.defaultWrapper = "mesa";
  nixGL.installScripts = [ "mesa" ];

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