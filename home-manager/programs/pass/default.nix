{lib, config, ...}:
let
  cfg = config.modules.programs.pass;
in
{
  options.modules.programs.pass = {
    enable = lib.mkEnableOption "Enable pass program";
  };
  config = lib.mkIf cfg.enable
  {
    programs.password-store = {
      enable = true;
      settings = {
        PASSWORD_STORE_DIR = "${config.xdg.dataHome}/pass"; 
      };
    };
  };
}
