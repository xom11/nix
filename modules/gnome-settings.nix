{ config
, pkgs
, inputs
, ...
}:
{
  dconf = {
    settings = {
        "org/gnome/mutter"={
          dynamic-workspaces=false;
          workspaces-only-on-primary=false;
        };
        "org/gnome/shell"={
          enable-hot-corners=false;
        };
    };
  };
}