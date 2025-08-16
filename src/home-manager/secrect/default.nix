{config, ...}:
{
  age = {
    secrets = {
      "envs" = {
        file = ./envs.age;
      };
    };
    identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
  };
  home.shellAliases = {
    nix-age-env = builtins.readFile config.age.secrets."envs".path;
  };
}