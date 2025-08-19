{config,dotfileDir,pkgs,   ...}:
{
  
  home.file = {
    ".config/sway/config" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/sway/config";
    };
    ".config/sway/run_or_raise.sh" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/sway/run_or_raise.sh";
    };
  };

}