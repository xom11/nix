{ pkgs, config, ... }:
{
  # Define the path to the kitty configuration file
  kittyConf = builtins.readFile ../../dotfiles/kitty/kitty.conf;
  
  # Enable the kitty program
  programs.kitty = {
    enable = true;
    setting = kittyConf
  };
}