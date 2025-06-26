
{ config, pkgs, lib, nixgl, ... }:
let 
  username = builtins.getEnv "USER"; 
in
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11"; 

  home.sessionVariables.SHELL = "${pkgs.zsh}/bin/zsh";

  imports = [
    ../../modules/tools
    ../../modules/gnome
    ../../modules/dotfiles
    ../../modules/bin
    ../../modules/desktop
    ../../modules/apps/linux
    ../../modules/fonts
    ../../modules/i18n
    ../../modules/services
  ];
  nixpkgs.config.allowUnfree = true;

  home.pointerCursor.gtk.enable = true;
  home.pointerCursor.package = pkgs.vanilla-dmz;
  home.pointerCursor.name = "Vanilla-DMZ";

  # ibus
  # xsession.windowManager.bspwm.startupPrograms = [
  #   "${pkgs.ibus}/bin/ibus restart || ${pkgs.ibus}/bin/ibus-daemon -d -r -x"
  # ];
  programs.home-manager.enable = true;
  home.shellAliases = {
    update = "nix run github:nix-community/home-manager -- switch --impure -b backup --refresh --flake github:kln-os/nix/main#desktop";
  }; 



}

