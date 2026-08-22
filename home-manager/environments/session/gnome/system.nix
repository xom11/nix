{lib}:
with lib.hm.gvariant; {
  "org/gnome/desktop/interface" = {
    show-battery-percentage = true;
    enable-hot-corners = false;
    enable-animations = false;
    color-scheme = "prefer-dark";
    gtk-theme = "Adwaita-dark";
  };
  "org/gnome/desktop/session" = {
    idle-delay = mkUint32 0;
  };
  "org/gnome/desktop/peripherals/keyboard" = {
    delay = mkUint32 200;
    repeat-interval = mkUint32 16;
  };
  "org/gnome/desktop/peripherals/mouse" = {
    speed = 0.2;
  };
  "org/gnome/desktop/peripherals/touchpad" = {
    click-method = "areas";
    speed = 0.4;
  };
  "org/gnome/desktop/input-sources" = {
    # xkb-options=["caps:hyper"];
    per-window = true;
    show-all-sources = true;
    sources = [(mkTuple ["xkb" "us"]) (mkTuple ["ibus" "Bamboo"])];
  };
  "org/gnome/settings-daemon/plugins/power" = {
    sleep-inactive-ac-type = "nothing";
    sleep-inactive-battery-type = "nothing";
    idle-dim = false;
  };
  # "org/gnome/desktop/background"={
  #   picture-uri-dark= builtins.toString ./. + "/background.jpg";
  # };
  "org/gnome/mutter" = {
    experimental-features = ["scale-monitor-framebuffer" "xwayland-native-scaling"];
    overlay-key = "Super_L";
    dynamic-workspaces = false;
    workspaces-only-on-primary = false;
    edge-tiling = false;
  };
  # Turn off sharing
  "org/gnome/mutter/wayland" = {
    xwayland-disable-extensions = ["Xtest"];
  };
}
