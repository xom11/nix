{config, dotfileDir, ...}:
{
  home.file = {
    ".config/kitty/kitty.conf" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/kitty/kitty.conf";
    };
  };
}
