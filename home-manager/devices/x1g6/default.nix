{ pkgs, device, lib, ... }:
lib.mkIf (device == "x1g6") 
{
  home.shellAliases = {
    update = ''
      git -C ~nix pull
      sudo nixos-rebuild switch --impure --refresh --flake ~/.nix#x1g6
    '';
  };
  modules = {
    i18n.enable = true;
    fonts.enable = true;
    x11.enable = true;
    programs ={
      apps.enable = true;
    };
  };
}