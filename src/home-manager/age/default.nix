{config, ...}:
{
  age = {
    secrets = {
      "github_token".file = ./secrets/github_token.age;
      "tailscale_key".file = ./secrets/tailscale_key.age;
      "openai_key".file = ./secrets/openai_key.age;
    };
    # identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
  };
  home.sessionVariables = {
    GITHUB_TOKEN = "$(cat ${config.age.secrets.github_token.path})";
    TAILSCALE_KEY = "$(cat ${config.age.secrets.tailscale_key.path})"; 
    OPENAI_KEY = "$(cat ${config.age.secrets.openai_key.path})";
  };
  home.shellAliases = {
    test_age =  "$(cat ${config.age.secrets.openai_key.path})";
  };
}