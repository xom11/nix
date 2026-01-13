{
  lib,
  config,
  pkgs,
  mkModule,
  ...
}: let
  inherit (builtins) filter map toString;
  inherit (lib.filesystem) listFilesRecursive;
  inherit (lib.strings) hasSuffix;
  luaFiles = filter (path: hasSuffix ".lua" (baseNameOf path)) (listFilesRecursive ./lua);
  extraConfigsLua = builtins.concatStringsSep "\n" (map builtins.readFile luaFiles);
in
  {
    imports = filter (hasSuffix ".nix") (
      map toString (filter (p: p != ./default.nix) (listFilesRecursive ./.))
    );
  }
  // mkModule config ./. {
    programs.nixvim = {
      enable = true;

      plugins = {
        auto-save.enable = true;
        # auto-session.enable = true;
        comment.enable = true;

        # https://github.com/folke/flash.nvim/
        # flash.enable = true;

        friendly-snippets.enable = true;
        luasnip.enable = true;
        nvim-autopairs.enable = true;
        tmux-navigator.enable = true;
        visual-multi.enable = true;
        web-devicons.enable = true;
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
      '';

      extraConfigLuaPost = ''
      '';

      extraConfigLua = extraConfigsLua;
    };
  }
