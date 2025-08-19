
{config, dotfileDir, ...}:
{
  home.file = {
    ".config/kglobalshortcutsrc" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/kglobalshortcutsrc";
    };
  };
}