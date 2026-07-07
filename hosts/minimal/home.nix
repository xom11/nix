{ pkgs, device, ... }:
let
  cfgDir = "~/.nix/hosts/${device}";
in
{
  imports = [
    ../../home-manager
  ];
  # Override homeDirectory to match VM HOME (/home/lenamkhanh.guest instead of /home/lenamkhanh)
  home.homeDirectory = builtins.getEnv "HOME";
  home.sessionVariables = {
      LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
  };
  modules.home-manager = {
    programs = {
      zsh.enable = true;
    };
  };
}
