
{ pkgs, ... }:

{
  programs.nixvim.plugins.arrow ={
    enable = true;
    settings = {
      show_icons = true;
      always_show_path = true;
      leader_key = "\t";
    }
    
}