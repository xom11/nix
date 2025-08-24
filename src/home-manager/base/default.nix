{ pkgs, username, dotfileDir, ... }:
{
  home.username = username;
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "brave";
    TERMINAL = "kitty";
    SHELL = "${pkgs.zsh}/bin/zsh";
    LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
    DOTFILE_DIR = "${dotfileDir}";
  };
}
