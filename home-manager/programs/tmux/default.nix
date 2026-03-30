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
        {
          plugin = fzf-tmux-url; # bind 'u' to choose a URL to open
          # add all config in first plugin
          extraConfig = "source-file ${tmuxDir}/plugins.conf";
        }
        open # bind 'o' to open a select URL
        yank
        vim-tmux-navigator
        power-theme
        resurrect
        continuum
        tmux-fzf
        tmux-floax
        tmux-sessionx
      ];
    };
    home.packages = with pkgs; [
      sesh
    ];
  }
