{ pkgs, config, ... }:
let 
  # Define the path to the tmux configuration file
  tmuxConf = builtins.readFile ../dotfiles/tmux/tmux.conf;
  tmuxReset = builtins.readFile ../dotfiles/tmux/tmux.reset.conf;
in 
{
  programs.tmux = {
    enable = true;
    prefix = "C-b";
    mouse = true;
    baseIndex = 1;
    terminal = "screen-256color";
    historyLimit = 1000000;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      vim-tmux-navigator
      cpu
      {
      plugin = catppuccin;
        extraConfig = ''
          # Configure the catppuccin plugin
          set -g @catppuccin_flavor "mocha"
          set -g @catppuccin_window_status_style "rounded"

          set -g status-right-length 100
          set -g status-left-length 100
          set -g status-left ""
          set -g status-right "#{E:@catppuccin_status_application}"
          set -agF status-right "#{E:@catppuccin_status_cpu}"
          set -ag status-right "#{E:@catppuccin_status_session}"
          set -ag status-right "#{E:@catppuccin_status_uptime}"
          set -agF status-right "#{E:@catppuccin_status_battery}"
        '';

      }
      ];
      extraConfig = tmuxReset; 
  };
}