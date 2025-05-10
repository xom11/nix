{ config
, pkgs
, inputs
, ...
}:
{
  dconf = {
    settings = {
        "org/gnome/desktop/wn/preferences/num-workspaces=4"; 
    };
  

}