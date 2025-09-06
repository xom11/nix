{lib, config, ...}:
let
  cfg = config.modules.programs.password-store;
in
{
  options.modules.programs.password-store = {
    enable = lib.mkEnableOption "Enable password-store program";
  };
  config = lib.mkIf cfg.enable
  {
    programs.password-store = {
      enable = true;
      settings = {
        PASSWORD_STORE_DIR = "${config.xdg.dataHome}/password-store"; 
      };
    };
  };
}
