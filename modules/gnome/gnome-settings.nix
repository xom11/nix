{ config, pkgs, inputs, lib, ...}:
with lib.hm.gvariant;

{
  home.packages = with pkgs;[
    gnome-bluetooth
    dconf2nix
    dconf-editor
  ];
  dconf.settings = {
    "org/gnome/mutter"={
      dynamic-workspaces=false;
      workspaces-only-on-primary=false;
    };
    "org/gnome/desktop/wm/preferences"={
      num-workspaces=4;
    };
    "org/gnome/shell"={
      favorite-apps=[];
    };
    "org/gnome/desktop/wm/keybindings"={
      close=["<Super>q"];
      switch-to-workspace-1=["<Super>1"];
      switch-to-workspace-2=["<Super>2"];
      switch-to-workspace-3=["<Super>3"];
      switch-to-workspace-4=["<Super>4"];
      toggle-maximized=["<Super>Up"];
      unmaximize=["<Super>Down"];
      show-desktop=["<Super>d"];
      minimize=["<Super>h"];
      always-on-top=["<Super>p"];
      cycle-windows=["<Hyper>bracketleft"];
      cycle-windows-backward=["<Hyper>bracketright"];
      begin-resize=["<Super>r"];
      begin-move=["<Super>m"];
      switch-input-source=["<Super><Shift>space" "XF86Keyboard"];
      switch-input-source-backward=[];
    };
    "org/gnome/shell/keybindings"={
      switch-to-application-1=[];
      switch-to-application-2=[];
      switch-to-application-3=[];
      switch-to-application-4=[];
      toggle-message-tray=[];
    };
    "org/gnome/shell/app-switcher"={
      current-workspace-only=true;
    };
    "org/gnome/desktop/interface"={
      show-battery-percentage=true;
      enable-hot-corners=false;
      enable-animations=false;
      color-scheme="prefer-dark";
      gtk-theme="Adwaita-dark";
    };
    "org/gnome/desktop/session"={
      idle-delay = mkUint32 0;
    };
    "org/gnome/desktop/peripherals/keyboard"={
      delay = mkUint32 200;
      repeat-interval = mkUint32 16;
    };
    "org/gnome/desktop/peripherals/mouse"={
      speed=0.4;
    };
    "org/gnome/desktop/peripherals/touchpad"={
      click-method="areas";
      speed=0.4;
    };
    "org/gnome/desktop/input-sources"={
      xkb-options=["caps:hyper"];
      per-window=true;
    };
    "org/gnome/settings-daemon/plugins/power"={
      sleep-inactive-ac-type="nothing";
      sleep-inactive-battery-type="nothing";
      idle-dim=false;
    };
    "org/gnome/desktop/background"={
      picture-uri-dark= builtins.toString ./.. + "/backgrounds/bg1.jpg";
    };
    "org/gnome/mutter"={
      experimental-features=["scale-monitor-framebuffer" "xwayland-native-scaling"];

    };
    # Turn off sharing
    "org/gnome/mutter/wayland"={
      xwayland-disable-extensions=["Xtest"];
    };
    "org/gnome/nautilus/preferences"={
      default-folder-viewer=true;
    };
    "org/gnome/settings-daemon/plugins/media-keys"={
      screensaver = ["<Super>l"];
      logout = ["<Super><Shift>l"];
      suspend = ["<Super><Shift>s"];
    };
  };
}