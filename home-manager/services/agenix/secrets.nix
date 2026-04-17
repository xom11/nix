let
  inherit (builtins) filter map toString attrNames readDir listToAttrs;
  lib = import <nixpkgs/lib>;
  inherit (lib.filesystem) listFilesRecursive;
  inherit (lib.strings) hasSuffix;

  users = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICtklD5ou04FnuluU8mT+YhryqPzOq/p/Zds3DQQ+IN2 macmini"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDDEXvxIw6DckDXhbt650gz0sthGm8xyt+PGfJ5OUA3x nixos"
  ];

  root = ../../..;
  allFiles = listFilesRecursive root;
  ageFiles = filter (f: hasSuffix ".age" (toString f)) allFiles;
in
  listToAttrs (map (f: {
    name = lib.removePrefix "./" (lib.path.removePrefix root f);
    value.publicKeys = users;
  }) ageFiles)
