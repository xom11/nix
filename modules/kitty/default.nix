{ pkgs, config, ... }:
{
  # Define the path to the kitty configuration file
  
  # Enable the kitty program
  programs.kitty = {
    enable = true;
    # settings = kittyConf;
  };
}