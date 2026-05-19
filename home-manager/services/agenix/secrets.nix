let
  inherit (builtins) filter map toString listToAttrs;
  lib = import <nixpkgs/lib>;
  inherit (lib.filesystem) listFilesRecursive;
  inherit (lib.strings) hasSuffix;

  publicKeys = import ./keys.nix;

  root = ../../..;
  allFiles = listFilesRecursive root;
  ageFiles = filter (f: hasSuffix ".age" (toString f)) allFiles;
in
  listToAttrs (map (f: {
    name = lib.removePrefix "./" (lib.path.removePrefix root f);
    value.publicKeys = publicKeys;
  }) ageFiles)
