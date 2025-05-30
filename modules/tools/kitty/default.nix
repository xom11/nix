{pkgs, lib, config, ...}:
{
  home.file.".config/kitty/kitty.conf".source = ./kitty.conf;
}