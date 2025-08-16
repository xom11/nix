let
  user1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICtklD5ou04FnuluU8mT+YhryqPzOq/p/Zds3DQQ+IN2 macmini";

in
{
  "secret1.age".publicKeys = [ user1 ];
  age.secrets.secret1.file = ./secret1.age;
}