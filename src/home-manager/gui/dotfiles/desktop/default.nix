{config, dotfileDir, ...}:
{
  home.file = {
    ".local/share/applications" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/desktop/applications";
    };
    ".local/share/icons" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/desktop/icons";
    };
  };
}