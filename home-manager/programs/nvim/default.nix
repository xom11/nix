{lib, config, pkgs, ... }:
let
  cfg = config.modules.programs.nvim;
  inherit (builtins) filter map toString;
  inherit (lib.filesystem) listFilesRecursive;
  inherit (lib.strings) hasSuffix;
in
{
  options.modules.programs.nvim = {
    enable = lib.mkEnableOption "Enable and configure Neovim";
  };
  imports = filter (hasSuffix ".nix") (
    map toString (filter (p: p != ./default.nix) (listFilesRecursive ./.))
  );
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
    ];
    programs.nixvim = {
      enable = true;
      globals.mapleader = " ";
      clipboard.register = "unnamedplus";
      opts = {
        expandtab = true;
        tabstop = 2;
        softtabstop = 2;
        shiftwidth = 2;
        number = false;
        relativenumber = false;
      };

      colorschemes.catppuccin.enable = true;

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
        visual-multi.enable = true;
        image.enable = true;
        barbecue.enable = true;
      };
      extraPlugins = with pkgs.vimPlugins; [
        vim-obsession   
      ];
    };
  };
}
