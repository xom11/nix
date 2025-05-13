{ config
, pkgs
, inputs
, ...
}:
{
  home.packages = with pkgs;[
    gnome-bluetooth
    dconf-editor
  ];
  dconf = {
    settings = {
      "org/gnome/mutter"={
        dynamic-workspaces=false;
        workspaces-only-on-primary=false;
      };
      "org/gnome/desktop/wm/preferences"={
        num-workspaces=4;
      };
      "org/gnome/desktop/wm/keybindings"={
        close=["<Super>q"];
        switch-to-workspace-1=["<Super>1"];
        switch-to-workspace-2=["<Super>2"];
        switch-to-workspace-3=["<Super>3"];
        switch-to-workspace-4=["<Super>4"];
        toggle-maximized=["<Super>Up"];
        show-desktop=["<Super>d"];
      };
      "org/gnome/shell/keybindings"={
        switch-to-application-1=[];
        switch-to-application-2=[];
        switch-to-application-3=[];
        switch-to-application-4=[];
      };
      "org/gnome/desktop/interface"={
        enable-hot-corners=false;
          enable-animations=false;
      };
      "org/gnome/desktop/session"={
        idle-delay=0;
      };
      "org/gnome/desktop/peripherals/keyboard"={
        delay=200;
        repeat-interval=16;
        };
      "org/gnome/desktop/peripherals/mouse"={
          speed=0.4;
        };
      "org/gnome/desktop/peripherals/touchpad"={
          speed=0.4;
        };
      "org/gnome/desktop/input-sources"={
          xkb-options=["caps:hyper"];
        };
      "org/gnome/settings-daemon/plugins/power"={
          sleep-inactive-ac-type="nothing";
          sleep-inactive-battery-type="nothing";
          idle-dim=false;
        };
      "org/gnome/mutter/wayland"={
        xwayland-disable-extensions=["Xtest"];
      }
    };
  };
}