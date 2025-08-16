{config, ...}:
#   user1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICtklD5ou04FnuluU8mT+YhryqPzOq/p/Zds3DQQ+IN2 macmini";

# in
{
  age = {
    secrets = {
      "secret1" = {
        file = ./secret1.age;
      };
    };
    identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
    # secretsDir = "/home/username/.local/share/agenix/agenix";
    # secretsMountPoint = "/home/username/.local/share/agenix/agenix.d";
  };
}