{config, ...}:
{
  age = {
    secrets = {
      "github_token".file = ./secrets/github_token.age;
      "tailscale_key".file = ./secrets/tailscale_key.age;
    };
    identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
  };
  home.sessionVariables = {
    GITHUB_TOKEN = "$(cat ${config.age.secrets.github_token.path})";
    TAILSCALE_KEY = "$(cat ${config.age.secrets.tailscale_key.path})"; 
  };
}