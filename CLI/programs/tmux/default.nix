{ pkgs, config, ... }:
let 
  tmuxConf = builtins.readFile ./tmux.conf;
in 
{
  home.packages = with pkgs; [
    tmux
  ];
  programs.tmux = {
    enable = true;
    extraConfig = tmuxConf; 

    plugins = with pkgs.tmuxPlugins; [
      # sensible
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
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          '';
      }
      {
        plugin = tmux-sessionx;
        extraConfig = ''
          set -g @sessionx-bind 'o'
          set -g @sessionx-window-height '90%'
          set -g @sessionx-window-width '90%'
          set -g @sessionx-zoxide-mode 'on'
          set -g @sessionx-fzf-marks-mode 'on'

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