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
      fzf-tmux-url
      yank
      vim-tmux-navigator
      {
        plugin = power-theme;
        extraConfig = ''
          set -g @tmux_power_time_format '%H:%M'
        '';
      }
      resurrect
      continuum
      {
        plugin = tmux-sessionx;
        extraConfig = ''
          set -g @sessionx-prefix off
          set -g @sessionx-window-height '90%'
          set -g @sessionx-window-width '90%'
          set -g @sessionx-zoxide-mode 'on'

        '';
      }
      tmux-fzf
      {
        plugin = tmux-floax;
        extraConfig = ''
          set -g @floax-bind '-n M-p'
          set -g @floax-width '90%'
          set -g @floax-height '90%'
        '';
      }
      ];
  };
}