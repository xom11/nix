
{ config, pkgs, lib, nixgl, ... }:
let 
  username = builtins.getEnv "USER"; 
in
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11"; 

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
    ../../CLI/client
    ../../CLI/vm
  ];
  nixpkgs.config.allowUnfree = true;

  home.sessionVariables = {
    SHELL = "${pkgs.zsh}/bin/zsh";
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
}

