{config, pkgs, lib, ...}:
let
  tmpConfig = pkgs.writeText "tmp" (builtins.readFile ./config);
  tmpAuthorizedKeys = pkgs.writeText "tmp" (builtins.readFile ./authorized_keys);
in
{
  home.activation = {

    copySshConfig =  lib.hm.dag.entryAfter ["writeBoundary"] ''
      rm -rf  "${config.home.homeDirectory}/.ssh/config"; 
      mkdir -p  "${config.home.homeDirectory}/.ssh";
      cp ${tmpConfig}  "${config.home.homeDirectory}/.ssh/config";
    '';

    copyAuthorizedKeys = lib.hm.dag.entryAfter ["writeBoundary"] ''
      rm -rf "${config.home.homeDirectory}/.ssh/authorized_keys";
      mkdir -p "${config.home.homeDirectory}/.ssh";
      cp ${./authorized_keys} "${config.home.homeDirectory}/.ssh/authorized_keys";
    '';

    genSshKey = lib.hm.dag.entryAfter ["copySshConfig"] ''
      if [ ! -f "${config.home.homeDirectory}/.ssh/id_ed25519" ]; then
        ssh-keygen -t ed25519 -f "${config.home.homeDirectory}/.ssh/id_ed25519" -N ""
      fi
    '';

  };
}