{ config, lib, pkgs, nixgl, ... }:

{
  nixGL.packages = import nixgl { inherit pkgs; };
  nixGL.defaultWrapper = "mesa";
  nixGL.installScripts = [ "mesa" ];

  home.packages = with pkgs; [
    (writeShellScriptBin "update-nix-app" (builtins.readFile ./update-nix-app.sh))
    (config.lib.nixGL.wrap kitty)
    brave
    vscode
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