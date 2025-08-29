{
  config,
  agenix,
  system,
  lib,
  ...
}:
let
  cfg = config.modules.secrets;
in
{
  options.modules.secrets = {
    enable = lib.mkEnableOption "Enable secrets management";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [
      agenix.packages.${system}.default
    ];
    age = {
      secrets = {
        "secret".file = ./secret.age;
      };
      identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
    };
  };  
}
