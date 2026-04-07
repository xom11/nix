{
  config,
  pkgs,
  getPath,
  mkModule,
  ...
}: let
  pwd = getPath ./.;
  targetDir = ".config/nvimx";
in
  mkModule config ./. {
    # programs.neovim = {
    #   enable = true;
    #   defaultEditor = true;
    #   viAlias = true;
    #   vimAlias = true;
    # };
    #
    # home.packages = with pkgs; [
    #   # conform formatters
    #   black
    #   shfmt
    #   stylua
    #   alejandra
    #   prettierd
    #   yamllint
    #   yamlfmt
    #   taplo
    # ];

    home.file = {
      # Own config files
      "${targetDir}/init.lua" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/init.lua";
      };
      "${targetDir}/lua/pack.lua" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/lua/pack.lua";
      };

      # Shared lua configs from nixvim
      "${targetDir}/lua/config/keymaps.lua" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/../nixvim/lua/config/keymaps.lua";
      };
      "${targetDir}/lua/config/options.lua" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/../nixvim/lua/config/options.lua";
      };
      "${targetDir}/lua/extras" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/../nixvim/lua/extras";
      };
      "${targetDir}/lua/plugins" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/../nixvim/lua/plugins";
      };
    };
  }
