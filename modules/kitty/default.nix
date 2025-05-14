{ pkgs, config, ... }:
let
  kittyConf = builtins.readFile ./kitty.conf;
in
{
  programs.kitty ={
    enable = true;
    extraConfig = kittyConf;
  };
}