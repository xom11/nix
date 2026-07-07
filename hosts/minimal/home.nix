{ pkgs, device, ... }:
let
  cfgDir = "~/.nix/hosts/${device}";
in
{
  imports = [
    ../../home-manager
  ];
  home.sessionVariables = {
      LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
  };
  modules.home-manager = {
    programs = {
      zsh.enable = true;
    };
  };
}
