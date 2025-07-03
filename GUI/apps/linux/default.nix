{ config, lib, pkgs, nixgl, ... }:

{
  nixGL.packages = import nixgl { inherit pkgs; };
  nixGL.defaultWrapper = "mesa";
  nixGL.installScripts = [ "mesa" ];

  home.packages = with pkgs; [
    (config.lib.nixGL.wrap kitty)
    (config.lib.nixGL.wrap localsend)
    telegram-desktop
    brave
    vscode

    ####
    # (config.lib.nixGL.wrap vscode)
    # discord
    # bitwarden-desktop
    # joplin-desktop
    # slack
    # google-chrome
    # chromedriver
    # caprine
  ];
  nixpkgs.config.brave.commandLineArgs = "--no-sandbox";

}
