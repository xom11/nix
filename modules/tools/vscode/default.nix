{config, pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    profiles.kln = {
      keybindings = ./keybindings.json;
      settings = ./settings.json;
    };

  };
}