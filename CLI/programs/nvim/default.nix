{pkgs, ...}:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    plugins = with pkgs.vimPlugins; [
      comment-nvim
      lualine-nvim
      nvim-web-devicons
      vim-tmux-navigator
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

    ];
    extraLuaConfig = ''
      ${builtins.readFile ./options.lua}
      ${builtins.readFile ./keymap.lua}
    '';
    programs.neovim.extraPackages = [
      pkgs.nodePackages_latest.vscode-json-languageserver
    ];
  };
}