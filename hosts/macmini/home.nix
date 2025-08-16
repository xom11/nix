{ pkgs, username, config, ... }:
{
  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "24.11"; 
  programs.home-manager.enable = true;

  home.sessionVariables.SHELL = "${pkgs.zsh}/bin/zsh";

  imports = builtins.map (name: ../../src/home-manager/${name}) [
    "gui/dotfiles"
    "gui/fonts"

    "cli/os/macos"
    "cli/programs"
    "cli/pkgs"
    "cli/base"
    "cli/secrect"
  ];

  nixpkgs.config.allowUnfree = true;
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "brave";
    TERMINAL = "kitty";
    SECRET1 = "$(cat ${config.age.secrets.secret1.path})";
  };
  home.shellAliases = {
    update = "sudo darwin-rebuild switch --impure --flake ~/.nix#macmini";
  };

}


