{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    prettierd
    black
    shfmt 
    stylua 
  ];
  imports = [
    ./cmp.nix
    ./treesitter.nix
    ./lsp.nix
    ./conform.nix
    ./neotree.nix
    ./telescope.nix
    ./transparent.nix
    ./keymaps.nix
    ./which-keys.nix
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
      relativenumber = true;
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
      gitsigns.enable = true;
      visual-multi.enable = true;
    };
  };
}
