{config, agenix, system, lib, device,...}:
lib.mkIf (device != "server")
{
  home.packages = [
    agenix.packages.${system}.default
  ];
  age = {
    secrets = {
      "secret".file = ./secret.age;
    };
    identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ]; 
  };

}