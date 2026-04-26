{
  pkgs,
  config,
  mkModule,
  getPath,
  ...
}: let
  pwd = getPath ./.;
in
  mkModule config ./. {
    home.file = {
      ".config/yazi/yazi.toml".source = config.lib.file.mkOutOfStoreSymlink "${pwd}/yazi.d/yazi.toml";
      ".config/yazi/keymap.toml".source = config.lib.file.mkOutOfStoreSymlink "${pwd}/yazi.d/keymap.toml";
      ".config/yazi/theme.toml".source = config.lib.file.mkOutOfStoreSymlink "${pwd}/yazi.d/theme.toml";
      ".config/yazi/init.lua".source = config.lib.file.mkOutOfStoreSymlink "${pwd}/yazi.d/init.lua";
      ".config/yazi/plugins/git.yazi".source = pkgs.yaziPlugins.git;
      ".config/yazi/plugins/smart-enter.yazi".source = pkgs.yaziPlugins.smart-enter;
    };
    home.packages = [
      pkgs.yazi
    ];
  }
