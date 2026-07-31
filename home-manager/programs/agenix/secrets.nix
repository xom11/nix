# Rules for the `agenix` CLI, found via $RULES. Every *.age in the tree gets
# the same recipient list.
#
# Deliberately builtins-only. The CLI evaluates this file standalone with
# nix-instantiate, outside the flake, so `import <nixpkgs/lib>` would make
# `agenix -e` depend on NIX_PATH -- which resolves `nixpkgs` through the flake
# registry by default, i.e. over the network. Editing a secret has to work
# offline, and on a fresh box before any channel exists.
let
  publicKeys = import ./keys.nix;

  root = ../../..;

  hasAgeSuffix = name: let
    n = builtins.stringLength name;
  in
    n > 4 && builtins.substring (n - 4) 4 name == ".age";

  # Hand-rolled rather than lib.filesystem.listFilesRecursive, which offers no
  # way to skip .git -- 1075 of this repo's 1712 files, walked on every CLI
  # call, and growing with every loose object. Nothing else is excluded: an
  # explicit blocklist beats "skip all dotdirs", which would drop a secret
  # silently if one ever landed under .github.
  walk = prefix: dir:
    builtins.concatLists (
      builtins.attrValues (
        builtins.mapAttrs (
          name: type:
            if type == "directory"
            then
              if name == ".git"
              then []
              else walk "${prefix}${name}/" (dir + "/${name}")
            else if hasAgeSuffix name
            then ["${prefix}${name}"]
            else []
        ) (builtins.readDir dir)
      )
    );
in
  builtins.listToAttrs (
    map (relPath: {
      name = relPath;
      value.publicKeys = publicKeys;
    })
    (walk "" root)
  )
