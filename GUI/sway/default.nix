{ lib, config, pkgs, ...}:

{
  imports = [
  ];
  home.packages = with pkgs; [
    galculator
  ];
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    checkConfig = false;
    extraConfig = builtins.readFile ./config;
    config.bars = [{
      command = "swaybar_command waybar";
      position = "top";
      mode = "dock";
    }];
  };
  programs.waybar = {
    enable = true;
    # style = builtins.readFile ./waybar/style.css;
  };
  # xdg.configFile."waybar/config".source = ./waybar/config.jsonc;
}