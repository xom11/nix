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
  };
}