let
  users = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICtklD5ou04FnuluU8mT+YhryqPzOq/p/Zds3DQQ+IN2 macmini"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDDEXvxIw6DckDXhbt650gz0sthGm8xyt+PGfJ5OUA3x nixos"
  ];
in {
  "secrets.d/secret.age".publicKeys = users;
  "secrets.d/zsh.age".publicKeys = users;
  "secrets.d/zsh-keys.age".publicKeys = users;
  "secrets.d/git-credentials.age".publicKeys = users;
}

