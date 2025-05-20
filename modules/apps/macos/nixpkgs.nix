{ pkgs }:

with pkgs;
let shared-packages = import ../shared/nixpkgs.nix { inherit pkgs; }; in
shared-packages ++ [
  dockutil
  # notion-app
  maccy
  raycast
]