{ pkgs, ... }:
let
in
{
  imports = [
    ../../home-manager
  ];
  home.homeDirectory = builtins.getEnv "HOME";
  home.sessionVariables = {
      LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
  };
  modules.home-manager = {
    programs = {
      zsh.enable = true;
      ssh.enable = true;
    };
  };
}
