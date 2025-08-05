{ config, pkgs, ... }:

{
  imports = [
    ./treesitter.nix

  ];
  programs.nixvim = {
    enable = true;
    globals.mapleader = " ";

    colorschemes.catppuccin.enable = true;

    plugins = {
      nix.enable = true;
      lualine.enable = true;

      lsp-lines.enable = true;
      lspkind.enable = true;

      neogit.enable = true;
      cmp-zsh.enable = true;
      noice.enable = true;
      colorizer.enable = true;
      luasnip.enable = true;

      notify.enable = true; 

      airline = {
        enable = true;
        #powerline = true;
        settings = {
          theme = "catppuccin";
        };
      };
    };
  };
}