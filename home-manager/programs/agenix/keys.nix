# Derived from SSH authorized_keys — single source of truth.
# Add a new key to home-manager/programs/ssh/authorized_keys and rebuild.
let
  raw = builtins.readFile ./../ssh/authorized_keys;
  lines = builtins.filter (s: s != "" && builtins.match "^#.*" s == null)
    (builtins.filter builtins.isString (builtins.split "\n" raw));
in
  lines
