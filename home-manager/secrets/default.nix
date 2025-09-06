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
        "zsh".file = ./zsh.age;
        "keys".file = ./keys.age;
      };
      identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
    };
    programs.zsh.initContent = ''
      if [ -f "${config.age.secrets.zsh.path}" ]; then
        source "${config.age.secrets.zsh.path}"
      fi

      if [ -f "${config.age.secrets.keys.path}" ]; then
        source "${config.age.secrets.keys.path}"
      fi
    '';

  };  
}
