{pkgs, lib, config, ...}:
{
  home.packages = with pkgs;[
    kitty
    vanilla-dmz
  ];
  home.file.".config/kitty".source = ./dotfiles;
}