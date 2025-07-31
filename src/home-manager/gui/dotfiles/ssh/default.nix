{config, pkgs, lib, dotfileDir, ...}:
{
  
  home.file = {
    ".ssh/config" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/ssh//config";
    };
  };
}