{lib, config, ...}:
let
  cfg = config.modules.programs.git;
in
{
  options.modules.programs.git = {
    enable = lib.mkEnableOption "Enable git program";
  };
  config = lib.mkIf cfg.enable
  {
    programs.git = {
      enable = true;
      userName  = "khanhkhanhlele";
      userEmail = "namkhanh20xx@gmail.com";
      extraConfig = {
        init.defaultBranch = "main";
        credential.helper = "store";
      };
    };
  };
}
