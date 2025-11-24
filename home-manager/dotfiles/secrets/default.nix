{
  config,
  agenix,
  system,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.secrets;
in
{
  options.modules.secrets = {
    enable = lib.mkEnableOption "Enable secrets management";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [
      agenix.packages.${system}.default
      pkgs.age
      pkgs.gnupg
      pkgs.pass
    ];
    age = {
      secrets = {
        "secret".file = ./secrects.d/secret.age;
        "zsh".file = ./secrects.d/zsh.age;
        "zsh-keys" = {
          file = ./secrects.d/zsh-keys.age;
        };
        "git-credentials" = {
          file = ./secrects.d/git-credentials.age;
          path = "${config.home.homeDirectory}/.git-credentials";
        };
      };
      identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
    };
    programs.zsh.initContent = ''
      if [ -f "${config.age.secrets.zsh-keys.path}" ]; then
        source "${config.age.secrets.zsh-keys.path}"
      fi
    '';
  };  
}
