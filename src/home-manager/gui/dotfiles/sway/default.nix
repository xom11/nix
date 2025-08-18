{config,dotfileDir,pkgs,   ...}:
{
  
  home.file = {
    ".config/sway/config" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/sway/config";
    };
  };

}