{config, pkgs, lib, ...}:
{
  
  home.activation = {

    copySshConfig =  lib.hm.dag.entryAfter ["writeBoundary"] ''
      rm -rf  ~/.config/qutebrowser; 
      mkdir -p  ~/.config/qutebrowser;
      cp ${./config.py}  ~/.config/qutebrowser/config.py;
      chmod u+w ~/.config/qutebrowser/config.py;
    '';

  };
}