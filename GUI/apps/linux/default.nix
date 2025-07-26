{ config, lib, pkgs, nixgl, ... }:

{
  nixGL = {
    packages = import nixgl { inherit pkgs; };
    defaultWrapper = "mesa";
    installScripts = ["mesa"];
  };

  home.packages = with pkgs; [
    (config.lib.nixGL.wrap kitty)
    (config.lib.nixGL.wrap localsend)
    telegram-desktop
    # vscode
    # google-chrome
    # brave
    # discord
    # bitwarden-desktop
    # slack
    # chromedriver
    # caprine
  ];

}
