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
      ".config/sesh" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/sesh.d";
      };
      "${tmuxDir}" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/tmux.d";
      };
    };
    programs.tmux = {
      enable = true;
      # tmux 3.7 aborts entering copy-mode (upstream #5267): the fresh
      # copy-mode grid's calloc'd linedata is not fully zeroed on macOS, so
      # grid_clear_lines frees garbage pointers. No upstream fix yet (master
      # only carries diagnostics: asserts + ASAN, unusable daily). Defensive
      # memset over the observed corruption; drop when a fixed release ships.
      package = pkgs.tmux.overrideAttrs (old: {
        patches = (old.patches or []) ++ [ ./5267-zero-linedata.patch ];
      });
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
