{config, ...}:
{
  age = {
    secrets = {
      "secret".file = ./secrets/secret.age;
    };
    identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ]; 
  };

}