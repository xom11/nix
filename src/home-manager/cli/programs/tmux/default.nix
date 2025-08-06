{ pkgs, config, ... }:
let 
  tmuxConf = builtins.readFile ./tmux.conf;
in 
{
  programs.tmux = {
    enable = true;
    extraConfig = tmuxConf; 

    plugins = with pkgs.tmuxPlugins; [
      # sensible
      fzf-tmux-url
      {
        plugin = yank;
        extraConfig = ''
          set -g @yank_action 'copy-pipe'
        '';
      }
      vim-tmux-navigator
      {
        plugin = power-theme;
        extraConfig = ''
          set -g @tmux_power_time_format '%H:%M'
        '';
      }
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-strategy-nvim 'session'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          '';
      }
      tmux-fzf
      {
        plugin = tmux-floax;
        extraConfig = ''
          set -g @floax-bind '-n M-t'
          set -g @floax-width '80%'
          set -g @floax-height '80%'
        '';
      }
      ];
  };
}
