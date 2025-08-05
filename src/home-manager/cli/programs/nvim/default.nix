{ config, pkgs, ... }:

{
  imports = [
    ./cmp.nix
    ./conform.nix
    ./dashboard.nix
    ./efmls.nix
    ./treesitter.nix
    ./lsp-format.nix
    ./lsp-servers.nix
    ./neotree.nix
    ./telescope.nix
    ./keymaps.nix
    ./bufferline.nix

  ];
  programs.nixvim = {
    enable = true;
    globals.mapleader = " ";

    colorschemes.catppuccin.enable = true;

    plugins = {
      nix.enable = true;
      lualine.enable = true;
      web-devicons.enable = true;

      lsp-lines.enable = true;
      lsp.enable = true;
      lspkind.enable = true;
      none-ls.sources.formatting.prettier.enable = true;
      nvim-autopairs.enable = true;

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