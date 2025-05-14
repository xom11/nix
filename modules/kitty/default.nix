{ pkgs, config, ... }:
{
  home.files."./.config/kitty" = {
    source = ./kitty.conf;
  };
}