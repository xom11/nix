{ config, pkgs, inputs, ...}:
# dconf dump /org/gnome/shell/extensions | dconf2nix 
{
  home.packages = with pkgs;[
    gnome-extension-manager
    gnome-shell-extensions

    gnomeExtensions.dash-to-dock
    gnomeExtensions.run-or-raise
    gnomeExtensions.clipboard-history
    gnomeExtensions.blur-my-shell
    gnomeExtensions.just-perfection
    gnomeExtensions.undecorate
    gnomeExtensions.switcher
    ];
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions=[
        "run-or-raise@edvard.cz"
        "clipboard-history@alexsaveau.dev"
        "blur-my-shell@aunetx"
        "dash-to-dock@micxgx.gmail.com"
        "just-perfection-desktop@just-perfection"
        "undecorate@sun.wxg@gmail.com"
        "switcher@landau.fi"
        ];
    };
    "org/gnome/shell/extensions/just-perfection" = {
      panel=false;
      animation=0;
      panel-in-overview=true;
      startup-status = 0;

    };
    "org/gnome/shell/extensions/dash-to-dock" = {
      apply-custom-theme = true;
      autohide = true;
      background-opacity = 0.15;
      custom-theme-shrink = true;
      dash-max-icon-size = 32;
      dock-fixed = false;
      dock-position = "RIGHT";
      extend-height = false;
      height-fraction = 1.0;
      hide-delay = 0.2;
      hot-keys = false;
      icon-size-fixed = true;
      intellihide = true;
      intellihide-mode = "ALL_WINDOWS";
      isolate-workspaces = true;
      preferred-monitor = -2;
      preferred-monitor-by-connector = "eDP-1";
      preview-size-scale = 0.0;
      show-delay = 0.2;
      show-favorites = false;
      show-show-apps-button = false;
      show-trash = false;
      transparency-mode = "FIXED";
    };
    "org/gnome/shell/extensions/blur-my-shell" = {
      blur-active-windows = true;
      blur-background-windows = true;
    };
    "org/gnome/shell/extensions/clipboard-history" = {
      toggle-menu=["<Super>v"];
    };
    "org/gnome/shell/extensions/run-or-raise" = {
      center-mouse-to-focused-window=true;
    };
    "org/gnome/shell/extensions/switcher" = {
      only-current-workspace=true;
      fade-enable=true;
      show-switcher=["<Super>Space"];
      font-size = mkUint32 30;
      icon-size = mkUint32 30;
      max-width-percentage = mkUint32 80;
    };
  };
  

}