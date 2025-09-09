{
  inputs,
  outputs,
  args,
  ...
}:
let
  mkConfigs = import ./mkConfigs.nix { inherit inputs outputs args; };
in
{
  inherit (mkConfigs)
    mkDarwin
    # mkNixos
    ;
}