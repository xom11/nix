{ config
, pkgs
, inputs
, lib
, ...
}:
{
  home.packages = with pkgs;
    [
    gnomeExtensions.run-or-raise
    gnomeExtensions.dash-to-dock
    gnomeExtensions.blur-my-shell
    gnomeExtensions.just-perfection
    gnomeExtensions.clipboard-history
    ];
  dconf = {
    # enabled = true;
    settings = {
      "org/gnome/shell/extensions/just-perfection" = {
        panel=false;
        animation=0;
        panel-in-overview=true;

      };
      "org/gnome/shell/extensions/dash-to-dock" = {
        apply-custom-theme=true;
        autohide=true;
        background-opacity=0.15;
        custom-theme-shrink=true;
        dash-max-icon-size=32;
        dock-fixed=false;
        dock-position="RIGHT";
        extend-height=false;
        height-fraction=1.0;
        icon-size-fixed=true;
        isolate-workspaces=true;
        preferred-monitor=-2;
        intellihide=true;
        intellihide-mode="ALL_WINDOWS";
        show-delay=0.0;
        preview-size-scale=0.0;
        show-favorites=false;
        show-show-apps-button=false;
        show-trash=false;
        transparency-mode="FIXED";
        hide-delay=0;
      };
      "org/gnome/shell/extensions/blur-my-shell" = {
        "blur-active-windows" = true;
        "blur-background-windows" = true;
      };
    };
  };
  

}