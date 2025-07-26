{config, pkgs, lib, ...}:
{
  home.activation = {
    copyRunOrRaise =  lib.hm.dag.entryAfter ["writeBoundary"] ''
      rm -rf ~/.config/run-or-raise; 
      mkdir -p ~/.config/run-or-raise;
      cp ${./shortcuts.conf} ~/.config/run-or-raise/shortcuts.conf;
      chmod u+w ~/.config/run-or-raise/shortcuts.conf;
    '';
  };
  home.file = {
    ".config/run-or-raise/shortcuts.conf" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix/GUI/gnome/run-or-raise/shortcuts.conf";
    };
  };
}