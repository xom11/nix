{config, pkgs, lib, ...}:
let
  tmpConfig = pkgs.writeText "tmp" (builtins.readFile ./config);
in
{
  home.activation = {
    copySshConfig =  lib.hm.dag.entryAfter ["writeBoundary"] ''
      rm -rf  "${config.home.homeDirectory}/.ssh/config"; 
      mkdir -p  "${config.home.homeDirectory}/.ssh";
      cp ${tmpConfig}  "${config.home.homeDirectory}/.ssh/config";
    '';
    genSshKey = lib.hm.dag.entryAfter ["copySshConfig"] ''
      if [ ! -f "${config.home.homeDirectory}/.ssh/id_ed25519" ]; then
        ssh-keygen -t ed25519 -f "${config.home.homeDirectory}/.ssh/id_ed25519" -N ""
      fi
    '';
  };
}