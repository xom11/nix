{pkgs, lib, config, ...}:
{
  home.packages = with pkgs;[
    kitty
  ];
  home.file.".config/kitty".source = ./dotfiles;
}