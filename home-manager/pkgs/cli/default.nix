{pkgs, lib, config, ...}:
let
  cfg = config.modules.pkgs.cli;
in
{
  options.modules.pkgs.cli = {
    enable = lib.mkEnableOption "Install CLI tools";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      caligula
      gemini-cli
    
      # Secret
      pass
      gnupg
      age

    ];
  };
}
