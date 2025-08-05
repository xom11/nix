{pkgs, ...}:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    plugins = with pkgs.vimPlugins; [
      comment-nvim
      {
        plugin = lualine-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/lualine.lua;
      }
      nvim-web-devicons
      vim-tmux-navigator
      render-markdown-nvim
      mini-nvim
      {
        plugin = transparent-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/transparent.lua;
      }
      {
        plugin = catppuccin-nvim;
        config = "colorscheme catppuccin";
      }
      {
        plugin = telescope-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/telescope.lua;
      }
      telescope-fzf-native-nvim
      {
        plugin = nvim-tree-lua;
        type = "lua";
        config = builtins.readFile ./plugins/nvim-tree.lua;
      }
      {
        plugin = nvim-treesitter;
        type = "lua";
        config = builtins.readFile ./plugins/treesitter.lua;
      }
      luasnip
      cmp-buffer
      cmp-path
      cmp-cmdline
      cmp-nvim-lsp
      {
        plugin = nvim-cmp;
        type = "lua";
        config = builtins.readFile ./plugins/nvim-cmp.lua;
      }
      {
        plugin = mason-nvim;
      }
      mason-lspconfig-nvim
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = builtins.readFile ./plugins/lspconfig.lua;
      }
      {
        plugin = nvim-notify;
        type = "lua";
        config = builtins.readFile ./plugins/notify.lua;
      }
      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/gitsigns.lua;
      }

    ];
    extraLuaConfig = ''
      ${builtins.readFile ./options.lua}
      ${builtins.readFile ./keymap.lua}
    '';
    extraPackages = with pkgs; [
      nodePackages_latest.vscode-json-languageserver
      python3Packages.python-lsp-server
      lua-language-server
      stylua
      nil

    ];
  };
}