
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
    # ./symlinks.nix
    ../../modules/tools
    ../../modules/gnome
    ../../modules/dotfiles
    ../../modules/bin
    ../../modules/desktop
    # ../../modules/apps
    ../../modules/fonts
  ];
  nixGL.packages = import nixgl { inherit pkgs; };
  nixGL.defaultWrapper = "mesa"; # or the driver you need
  nixGL.installScripts = [ "mesa" ];

  home.packages = with pkgs; [
    (config.lib.nixGL.wrap alacritty)
    (config.lib.nixGL.wrap vscode)
    (config.lib.nixGL.wrap brave)
    (config.lib.nixGL.wrap kitty)

  ];

  nixpkgs.config.allowUnfree = true;

  home.pointerCursor.gtk.enable = true;
  home.pointerCursor.package = pkgs.vanilla-dmz;
  home.pointerCursor.name = "Vanilla-DMZ";

  # ibus
  xsession.windowManager.bspwm.startupPrograms = [
    "${pkgs.ibus}/bin/ibus restart || ${pkgs.ibus}/bin/ibus-daemon -d -r -x"
  ];
  programs.home-manager.enable = true;
  home.shellAliases = {
    update = "nix run github:nix-community/home-manager -- switch --impure -b backup --refresh --flake github:kln-os/nix/main#desktop";
  }; 



}

