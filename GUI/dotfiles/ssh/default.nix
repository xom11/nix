{config, pkgs, lib, ...}:
{
  
  home.activation = {

    copySshConfig =  lib.hm.dag.entryAfter ["writeBoundary"] ''
      rm -rf  ~/.ssh/config; 
      mkdir -p  ~/.ssh;
      cp ${./config}  ~/.ssh/config;
      chmod u+w ~/.ssh/config;
    '';

  };
}