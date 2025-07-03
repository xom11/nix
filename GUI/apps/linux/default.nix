{ config, lib, pkgs, nixgl, ... }:

{
  nixGL.packages = import nixgl { inherit pkgs; };
  nixGL.defaultWrapper = "mesa";
  nixGL.installScripts = [ "mesa" ];

  home.packages = with pkgs; [
    (config.lib.nixGL.wrap kitty)
    (config.lib.nixGL.wrap localsend)
    (config.lib.nixGL.wrap google-chrome)
    (config.lib.nixGL.wrap brave)
    telegram-desktop
    vscode
    # google-chrome
    # brave

    ####
    # (config.lib.nixGL.wrap vscode)
    # discord
    # bitwarden-desktop
    # joplin-desktop
    # slack
    # chromedriver
    # caprine
  ];

}
