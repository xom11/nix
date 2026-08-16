{
  lib,
  pkgs,
}:
with lib.hm.gvariant; {
  packages = with pkgs; [
    gnomeExtensions.dash-to-dock
    gnomeExtensions.clipboard-history
    gnomeExtensions.blur-my-shell
    gnomeExtensions.just-perfection
    gnomeExtensions.undecorate
    gnomeExtensions.switcher
    gnomeExtensions.kimpanel
    beckon-gnome-extension
  ];
  dconf = {
    "org/gnome/shell" = {
      favorite-apps = [];
      # CONG TAC TONG. Bat len la MOI extension nguoi dung bi tat, bat ke
      # enabled-extensions liet ke gi -- ca 8 cai duoi day deu khong nap.
      # Trieu chung rat de doc nham: `gnome-extensions list` van liet ke du,
      # `gnome-extensions info` bao State: INITIALIZED, va `gnome-extensions
      # enable <uuid>` chay khong bao loi nhung Enabled van la No.
      # Do tren VM 09/08/2026: beckon tren GNOME Wayland can extension
      # beckon@xom11.github.io (Mutter chan focus tu ngoai), extension da cai
      # dung cho va co trong enabled-extensions, nhung khoa nay = true nen
      # beckon bao "extension not reachable on D-Bus" va MOI phim tat trong
      # apps.shared.toml chay lenh xong khong mo duoc app nao.
      disable-user-extensions = false;
      disable-extension-version-validation = true;
      enabled-extensions = [
        "clipboard-history@alexsaveau.dev"
        "blur-my-shell@aunetx"
        "kimpanel@kde.org"
        "dash-to-dock@micxgx.gmail.com"
        "just-perfection-desktop@just-perfection"
        "undecorate@sun.wxg@gmail.com"
        "switcher@landau.fi"
        "beckon@xom11.github.io"
      ];
    };
    "org/gnome/shell/extensions/just-perfection" = {
      panel = false;
      dask = false;
      animation = 0;
      panel-in-overview = true;
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
      toggle-menu = ["<Alt>v"];
    };
    "org/gnome/shell/extensions/switcher" = {
      only-current-workspace = true;
      fade-enable = true;
      show-switcher = ["<Super>Space"];
      font-size = mkUint32 30;
      icon-size = mkUint32 30;
      max-width-percentage = mkUint32 80;
    };
  };
}
