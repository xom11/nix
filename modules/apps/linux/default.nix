{ config, lib, pkgs, nixgl, ... }:

{
  imports = [
    ../share
  ];
  nixGL.packages = import nixgl { inherit pkgs; };
  # nixGL.defaultWrapper = "mesa";
  # nixGL.installScripts = [ "mesa" ];

  home.packages = with pkgs; [
    (writeShellScriptBin "update-nix-app" (builtins.readFile ./update-nix-app.sh))
    (config.lib.nixGL.wrap kitty)
    # (config.lib.nixGL.wrap brave)
    brave
    # (config.lib.nixGL.wrap discord)
    # (config.lib.nixGL.wrap vscode)
    # (config.lib.nixGL.wrap google-chrome)
    # bitwarden-desktop
    # telegram-desktop
    # localsend
    # joplin-desktop
    # slack
    # thunderbird
    # google-chrome
    # chromedriver
    # caprine
  ];
}
