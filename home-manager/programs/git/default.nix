{
  config,
  mkModule,
  pkgs,
  getPath,
  ...
}: let
  pwd = getPath ./.;
in
  mkModule config ./. {
    home.file = {
      ".config/git/config" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/git.d/config";
      };
      ".config/gh-dash/config.yml" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/gh-dash.d/config.yml";
      };
    };
    home.packages = with pkgs; [
      git
      gh-dash
      delta
      lazygit
      diffnav
    ];
  }
