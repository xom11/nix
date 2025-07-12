{config, pkgs, lib, ...}:
let
  folder = "${config.home.homeDirectory}/.ssh";
  file = "${config.home.homeDirectory}/.ssh/config";
  tmp = pkgs.writeText "tmp" (builtins.readFile ./config);
in
{
  home.activation = {
    copySshConfig =  lib.hm.dag.entryAfter ["writeBoundary"] ''
      rm -rf ${file}; 
      mkdir -p ${folder};
      cp ${tmp} ${file};
    '';
  };
}