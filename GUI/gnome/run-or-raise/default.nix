{config, pkgs, lib, ...}:
let
  RunOrRaisePath = "${config.home.homeDirectory}/.config/run-or-raise";
  RunOrRaiseFile = pkgs.writeText "tmp" (builtins.readFile ./shortcuts.conf);
in
{
  home.activation = {
    copyRunOrRaise =  lib.hm.dag.entryAfter ["writeBoundary"] ''
      rm -rf ${RunOrRaisePath}; 
      mkdir -p ${RunOrRaisePath};
      cp ${RunOrRaiseFile} ${RunOrRaisePath}/shortcuts.conf;
    '';
};
}