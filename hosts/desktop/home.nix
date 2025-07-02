
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
    ../../GUI/gnome
    ../../GUI/dotfiles
    ../../GUI/desktop
    ../../GUI/apps/linux
    ../../GUI/fonts
    ../../GUI/i18n

    ../../CLI/bin
    ../../CLI/services
    ../../CLI/programs
    ../../CLI/pkgs
  ];
  nixpkgs.config.allowUnfree = true;

  # home.pointerCursor.gtk.enable = true;
  # home.pointerCursor.package = pkgs.vanilla-dmz;
  # home.pointerCursor.name = "Vanilla-DMZ";

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "brave";
    TERMINAL = "kitty";
  };

  home.shellAliases = {
    update = "nix run github:nix-community/home-manager -- switch --impure -b backup --refresh --flake github:kln-os/nix/main#desktop";
  }; 

  # show desktop apps
  targets.genericLinux.enable = true;
  programs.home-manager.enable = true;
  home.file.".config/environment.d/nix-path.conf".text= ''
      PATH="$HOME/.nix-profile/bin:$PATH"
    '';
  # home.activation = {
  #   linkGnomeExtensions = {
  #     after = [ "writeBoundary" "createXdgUserDirectories" ];
  #     before = [ ];
  #     data = ''
  #       ln -sf ${config.home.homeDirectory}/.nix-profile/share/gnome-shell/extensions ${config.home.homeDirectory}/.local/share/gnome-shell/
  #     '';
  #   };
  # };
}

