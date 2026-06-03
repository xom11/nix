{
  config,
  getPath,
  mkModule,
  pkgs,
  ...
}: let
  pwd = getPath ./.;
in
  mkModule config ./. {
    home.file = {
      ".config/kitty/kitty.conf".source = config.lib.file.mkOutOfStoreSymlink "${pwd}/kitty.d/kitty.conf";
      ".config/kitty/theme.conf".source = config.lib.file.mkOutOfStoreSymlink "${pwd}/kitty.d/theme.conf";
      ".config/kitty/platform.conf".text =
        if pkgs.stdenv.isLinux
        then ''
          map ctrl+v paste_from_clipboard
          map ctrl+c copy_or_interrupt
        ''
        else "";
    };
  }
