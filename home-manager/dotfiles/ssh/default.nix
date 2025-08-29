{lib, config, dotfileDir, ...}:
let
  cfg = config.modules.dotfiles.ssh;
in
{
  options.modules.dotfiles.ssh = {
    enable = lib.mkEnableOption "Enable ssh dotfiles";
  };
  config = lib.mkIf cfg.enable{
    home.file = {
      ".ssh/config" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/ssh/config";
      };
    };
  };
}