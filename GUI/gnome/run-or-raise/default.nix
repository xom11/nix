{config, pkgs, lib, ...}:
{
  home.activation = {
    copyRunOrRaise =  lib.hm.dag.entryAfter ["writeBoundary"] ''
      rm -rf ~/.config/run-or-raise; 
      mkdir -p ~/.config/run-or-raise;
      cp ${./shortcuts.conf} ~/.config/run-or-raise/shortcuts.conf;
    '';
  };
}