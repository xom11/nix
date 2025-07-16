{ config, lib, pkgs, ... }:

{
  imports = [
    ../../LINUX/base
    ../../LINUX/services
  ];
  home.file.".config/environment.d/system-manager-path.conf".text= ''
    PATH="$HOME/.nix-profile/bin:$PATH"
  '';
}