{config, dotfileDir, ...}:
{
  home.file = {
    ".config/btop/btop.conf" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/btop/btop.conf";
    };
  };
}
