{ config, lib, pkgs, nixgl, ... }:

{
  nixGL.packages = import nixgl { inherit pkgs; };
  # nixGL.defaultWrapper = "mesa";
  # nixGL.installScripts = [ "mesa" ];

  home.packages = with pkgs; [
    (config.lib.nixGL.wrap kitty)
    telegram-desktop
    localsend

    ####
    # (config.lib.nixGL.wrap vscode)
    # brave
    # discord
    # vscode
    # bitwarden-desktop
    # joplin-desktop
    # slack
    # google-chrome
    # chromedriver
    # caprine
  ];

}
