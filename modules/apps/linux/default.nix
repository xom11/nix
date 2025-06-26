{ config, lib, pkgs, nixgl, ... }:

{
  nixGL.packages = import nixgl { inherit pkgs; };
  # nixGL.defaultWrapper = "mesa"; # or the driver you need
  # nixGL.installScripts = [ "mesa" ];

  home.packages = with pkgs; [
    (config.lib.nixGL.wrap kitty)
    (config.lib.nixGL.wrap brave)
    (config.lib.nixGL.wrap vscode)

  ];
}