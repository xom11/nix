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
      nixpkgs.config.allowUnfree = true;
      colorschemes.catppuccin.enable = true;

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
