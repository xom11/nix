{ inputs, ... }:
let
  mkConfigs = import ./mkConfigs.nix { inherit inputs ; };
in
{
  inherit (mkConfigs)
    mkDarwin
    mkNixos
    ;
}