{ config, lib, pkgs, nixgl, ... }:

{
  nixGL = {
    packages = nixgl.packages;
    defaultWrapper = "mesa";
    installScripts = ["mesa"];
    vulkan.enable = true;
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
    # joplin-desktop
    # slack
    # chromedriver
    # caprine
  ];

}
