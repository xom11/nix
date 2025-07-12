{config, pkgs, lib, ...}:
let
  RunOrRaisePath = "${config.home.homeDirectory}/.config/run-or-raise";
  RunOrRaise = pkgs.writeText "tmp" (builtins.readFile ./shortcuts.conf);
in
{
  home.activation = {
    removeRunOrRaise = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
      rm -rf ${RunOrRaisePath}; 
    '';
    copyRunOrRaise =  lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      rm -rf ${RunOrRaisePath}; 
      mkdir -p ${RunOrRaisePath};
      cp ${RunOrRaise} ${RunOrRaisePath}/shortcuts.conf;
    '';
};
}