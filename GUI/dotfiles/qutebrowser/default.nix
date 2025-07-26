{config, pkgs, lib, ...}:
let
  qutebrowserConfigDir = if pkgs.stdenv.hostPlatform.isLinux
    then "~/.config/qutebrowser"
    else "~/.qutebrowser"; 
in
{
  
  # home.activation = {

  #   copyQutebrowserConfig =  lib.hm.dag.entryAfter ["writeBoundary"] ''
  #     rm -rf  ${qutebrowserConfigDir}; 
  #     mkdir -p  ${qutebrowserConfigDir};
  #     cp ${./config.py}  ${qutebrowserConfigDir}/config.py;
  #     cp ${./quickmarks}  ${qutebrowserConfigDir}/quickmarks;
  #     chmod -R u+w ${qutebrowserConfigDir};
  #   '';

  # };

  home.file = {
    "test" = {
      source = config.lib.file.mkOutOfStoreSymlink ./config.py;
    };
  };
}