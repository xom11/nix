{pkgs, ...}:
{
  # home.packages = with pkgs; [
  #   neovim
  # ]; 

  # home.file = {
  #     ".config/nvim".source = ./dotfiles;
  # };


  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    plugins = with pkgs.vimPlugins; [
      ## regular
      comment-nvim
      lualine-nvim
      nvim-web-devicons
      vim-tmux-navigator
      {
        plugin = catppuccin-nvim;
        config = "colorscheme catppuccin";
      }

      ## telescope
      {
        plugin = telescope-nvim;
        type = "lua";
        config = builtins.readFile ./plugins/telescope.lua;
      }
      telescope-fzf-native-nvim

    ];
    extraLuaConfig = ''
      ${builtins.readFile ./options.lua}
      ${builtins.readFile ./keymap.lua}
    '';
  };
}