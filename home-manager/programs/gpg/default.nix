
{lib, config, ...}:
let
  cfg = config.modules.programs.gpg;
in
{
  options.modules.programs.gpg = {
    enable = lib.mkEnableOption "Enable gpg program";
  };
  config = lib.mkIf cfg.enable
  {
    programs.gpg = {
      enable = true;
      homedir = "${config.xdg.dataHome}/gnupg";
    };
  };
}
