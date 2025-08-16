{config, ...}:
{
  age = {
    secrets = {
      "github_token" = {
        file = ./secrect/github_token.age;
      };
    };
    identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
  };
  home.sessionVariables = {
    GITHUB_TOKEN = "$(cat ${config.age.secrets.github_token.path})";
  };
}