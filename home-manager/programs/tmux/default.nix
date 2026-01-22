{
  pkgs,
  config,
  getPath,
  mkModule,
  ...
}: let
  tmuxDir = "${config.xdg.configHome}/tmux/tmux.d";
  pwd = getPath ./.;
in
  mkModule config ./. {
    home.file = {
      "${tmuxDir}" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/tmux.d";
      };
    };
    programs.tmux = {
      enable = true;
      extraConfig = ''
        source-file ${tmuxDir}/tmux.conf
      '';
      plugins = with pkgs.tmuxPlugins; [
        # sensible
        # bind 'u' to choose a URL to open
        fzf-tmux-url
        # bind 'o' to open a select URL
        open
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
          # https://github.com/omerxx/tmux-floax
          extraConfig = ''
            set -g @floax-bind 't'
            set -g @floax-width '80%'
            set -g @floax-height '80%'
          '';
        }
        {
          plugin = tmux-sessionx;
          # https://github.com/omerxx/tmux-sessionx
          extraConfig = ''
            set -g @sessionx-bind 's'
            set -g @sessionx-window-height '90%'
            set -g @sessionx-window-width '90%'
            set -g @sessionx-bind-kill-session 'ctrl-w'
            set -g @sessionx-bind-window-mode 'ctrl-s'
          '';
        }
      ];
    };
  }
