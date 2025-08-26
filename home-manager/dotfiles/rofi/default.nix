
{lib, device, config, dotfileDir, ...}:
{
  home.file = {
    ".config/rofi/config.rasi" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/rofi/config.rasi";
    };
    ".config/rofi/theme.rasi" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/rofi/theme.rasi";
    };
  };
}
