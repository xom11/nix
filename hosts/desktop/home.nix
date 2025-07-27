
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
    update = "nix run github:nix-community/home-manager -- switch --impure -b backup --refresh --flake ~/.nix#desktop";
    system-update = "git -C ~/nix pull && sudo /nix/var/nix/profiles/default/bin/nix run 'github:numtide/system-manager' -- switch --flake ~/.nix#desktop"; 
  }; 

  # show desktop apps
  targets.genericLinux.enable = true;
  programs.home-manager.enable = true;
  home.file.".config/environment.d/nix-path.conf".text= ''
      PATH="$HOME/.nix-profile/bin:$PATH"
    '';

  # system manager path
  programs.zsh.initContent = ''
      # source system manager path
      if [ -d /run/system-manager/sw/bin ]; then
        export PATH="/run/system-manager/sw/bin/:$PATH"
      fi
    '';

  
    
}

