{ config, lib, pkgs, nixgl, ... }:

{
  nixGL.packages = import nixgl { inherit pkgs; };
  nixGL.defaultWrapper = "mesa"; # or the driver you need
  nixGL.installScripts = [ "mesa" ];

  home.packages = with pkgs; [
    # Example alacritty
    (config.lib.nixGL.wrap kitty)

    # Other packages that do not require nixGL:
    bat
    neovim
    # ...
  ];
}