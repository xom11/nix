{ config, lib, pkgs, nixgl, ... }:

{
  imports = [
    ../desktop
    ../programs
    ../pwa
  ];
  nixGL = {
    packages = import nixgl { inherit pkgs; };
    defaultWrapper = "mesa";
    installScripts = ["mesa"];
  };

  home.packages = with pkgs; [
    (config.lib.nixGL.wrap kitty)
    (config.lib.nixGL.wrap localsend)
    telegram-desktop
  ];

}
