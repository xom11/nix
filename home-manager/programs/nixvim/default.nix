{
  lib,
  config,
  pkgs,
  mkModule,
  getPath,
  ...
}: let
  inherit (builtins) filter map toString;
  inherit (lib.filesystem) listFilesRecursive;
  inherit (lib.strings) hasSuffix;
  pwd = getPath ./.;
in
  {
    imports = filter (hasSuffix ".nix") (
      map toString (filter (p: p != ./default.nix) (listFilesRecursive ./.))
    );
  }
  // mkModule config ./. {
    programs.nixvim = {
      enable = true;
      colorschemes.catppuccin.enable = true;
      plugins = {
        auto-save.enable = true;
        # auto-session.enable = true;
        comment.enable = true;
        friendly-snippets.enable = true;
        luasnip.enable = true;
        nvim-autopairs.enable = true;
        tmux-navigator.enable = true;
        visual-multi.enable = true;
        web-devicons.enable = true;
        neo-tree = {
          enable = true;
          settings = {__raw = "require('opts.neotree')";};
        };
        toggleterm = {
          enable = true;
          settings = {__raw = "require('opts.toggleterm')";};
        };
        which-key = {
          enable = true;
          settings = {__raw = "require('opts.which-key')";};
        };
      };

      extraPlugins = with pkgs.vimPlugins; [
        vim-obsession
        # clipboard-image-nvim
      ];

      extraConfigVim = ''
      '';

      extraConfigLuaPre = ''
        if vim.g.have_nerd_font then
          require('nvim-web-devicons').setup {}
        end

        -- Add the current directory to runtime path to load extra Lua configs
        vim.opt.rtp:append("${pwd}")

        require('config.options')

        require('extras')

      '';

      extraConfigLuaPost = ''
        require('config.keymaps')
      '';

      extraConfigLua = ''

    '';
    };
  }
