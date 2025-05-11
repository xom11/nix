
{ config, pkgs, ... }:

{
  home.username = builtins.getEnv "USER";  
  home.homeDirectory = builtins.getEnv "HOME";  
  home.stateVersion = "23.11"; 

  # user.shell = pkgs.zsh;

  imports = [
    ./modules
  ];

  home.file = {
    ".zshrc".source = ./dotfiles/zsh/.zshrc;
    ".config/atuin".source = ./dotfiles/atuin;
    ".config/kitty".source = ./dotfiles/kitty;
    ".config/run-or-raise".source = ./dotfiles/run-or-raise;
    ".config/tmux".source = ./dotfiles/tmux;
    ".config/nvim".source = ./dotfiles/nvim;
    ".config/nix".source = ./dotfiles/nix;
  };

  home.sessionPath = [
    "/run/current-system/sw/bin"
      "$HOME/.nix-profile/bin"
  ];

  programs.home-manager.enable = true;

  # git 
  programs.git.enable = true;
  programs.git.userName = "khanhkhanhlele";
  programs.git.userEmail = "namkhanh20xx@gmail.com";
  nixpkgs.config.allowUnfree = true;

  # Environment
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "brave";
    TERMINAL = "kitty";
    GTK_IM_MODULE = "ibus";
    XMODIFIERS = "@im=ibus";
    QT_IM_MODULE = "ibus";
  };

  # ibus
  xsession.windowManager.bspwm.startupPrograms = [
    "${pkgs.ibus}/bin/ibus restart || ${pkgs.ibus}/bin/ibus-daemon -d -r -x"
  ];

}

