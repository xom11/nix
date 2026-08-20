{
  config,
  pkgs,
  mkModule,
  getPath,
  ...
}: let
  pwd = getPath ./.;
in
  mkModule config ./. {
    # Ships the PROGRAM, not just config. The binary used to come only from the
    # i3/sway modules, so a host enabling dotfiles.rofi without them deployed
    # config.rasi and theme.rasi for a program that DID NOT EXIST. Same class of
    # bug as kitty: config in one module, package in another, and nothing warns
    # when only half is enabled. Overlapping with another module is harmless,
    # since home.packages is a union.
    home.packages = [pkgs.rofi];

    home.file = {
      ".config/rofi/config.rasi" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/config.rasi";
      };
      ".config/rofi/theme.rasi" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/theme.rasi";
      };
    };
  }
