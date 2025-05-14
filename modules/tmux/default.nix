{ pkgs, config, ... }:
let 
  # Define the path to the tmux configuration file
  keybindingsConf = builtins.readFile ./keybindings.conf;
  tmuxConf = builtins.readFile ./tmux.conf;
  allConf = keybindingsConf + tmuxConf;
in 
{
  home.packages = with pkgs; [
    tmux
  ];
  programs.tmux = {
    enable = true;
    extraConfig = allConf; 

    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      vim-tmux-navigator
      resurrect
      power-theme
      continuum
      tmux-sessionx
      tmux-fzf
      tmux-floax
      ];
  };
}