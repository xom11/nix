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
      settings = {
        user = {
          name  = "khanhkhanhlele";
          email = "namkhanh2172@gmail.com";
        };
        init.defaultBranch = "main";
        credential.helper = "store";
      };
    };
  };
}
