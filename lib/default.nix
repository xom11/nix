{ inputs, flakeOverlays, ... }:
let
  mkConfigs = import ./mkConfigs.nix { inherit inputs flakeOverlays; };
in
{
  inherit (mkConfigs)
    mkDarwin
    mkNixos
    mkHomeManager
    mkSystemManager
    ;
}
