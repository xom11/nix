{config, pkgs, lib, ...}:
let
  RunOrRaisePath = "${config.home.homeDirectory}/.config/run-or-raise/shortcuts.conf";
  RunOrRaise = pkgs.writeText "tmp" (builtins.readFile ./shortcuts.conf);
in
{
  home.activation = {
    removeRunOrRaise = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
      rm -rf ${RunOrRaisePath}; 
    '';
    copyRunOrRaise =  lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      rm -rf ${RunOrRaisePath}; 
      cp "${RunOrRaise}" "${RunOrRaisePath}";
      chmod +x '${RunOrRaisePath}'; 
    '';
};
}