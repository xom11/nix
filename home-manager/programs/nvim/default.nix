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
in
  {
    imports = filter (hasSuffix ".nix") (
      map toString (filter (p: p != ./default.nix) (listFilesRecursive ./.))
    );
  }
  // mkModule config ./. {
    home.packages = with pkgs; [
    ];
    programs.nixvim = {
      enable = true;

      plugins = {
        lualine.enable = true;
        luasnip.enable = true;
        friendly-snippets.enable = true;
        render-markdown.enable = true;
        nvim-autopairs.enable = true;
        dashboard.enable = true;
        tmux-navigator.enable = true;
        web-devicons.enable = true;
        noice.enable = true;
        comment.enable = true;
        colorizer.enable = true;
        auto-save.enable = true;
        # auto-session.enable = true;
        visual-multi.enable = true;
        image.enable = true;
        barbecue.enable = true;
        # flash.enable = true;
        lazygit.enable = true;
      };
      extraPlugins = with pkgs.vimPlugins; [
        vim-obsession
      ];
    };
  }
