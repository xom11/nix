{ pkgs, config, ... }:
let
  kittyConf = builtins.readFile ./kitty.conf;
in
{
  programs.kitty ={
    enable = true;
    extraConfig = kittyConf;
  };
  # home.file ={
  #   ".config/kitty/kitty.conf".source = ./kitty.conf;
  #   # ".config/kitty/kitty-reset.conf".source = ./dotfiles/kitty/kitty.reset.conf;
  # };
}