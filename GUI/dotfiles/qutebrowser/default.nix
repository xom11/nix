{config, pkgs, lib, ...}:
let
  qutebrowserConfigDir = if pkgs.stdenv.hostPlatform.isLinux
    then "~/.config/qutebrowser"
    else "~/.qutebrowser"; 
in
{
  
  home.activation = {

    copyQutebrowserConfig =  lib.hm.dag.entryAfter ["writeBoundary"] ''
      rm -rf  ${qutebrowserConfigDir}/config.py; 
      mkdir -p  ${qutebrowserConfigDir};
      cp ${./config.py}  ${qutebrowserConfigDir}/config.py;
      chmod u+w ${qutebrowserConfigDir}/config.py;
    '';

  };
}