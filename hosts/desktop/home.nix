
{ config, pkgs, lib, nixgl, ... }:
let 
  username = builtins.getEnv "USER"; 
in
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11"; 

imports = builtins.map (name: ../../src/home-manager/${name}) [
  "gui/gnome"
  "gui/dotfiles"
  "gui/apps/linux"
  "gui/fonts"
  "gui/i18n"

  "cli/bin"
  "cli/services"
  "cli/programs"
  "cli/pkgs"
  "cli/client"
  "cli/vm"
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
    system-update = "sudo /nix/var/nix/profiles/default/bin/nix run 'github:numtide/system-manager' -- switch --flake ~/.nix#desktop"; 
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

