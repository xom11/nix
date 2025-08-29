{ lib, config, ... }:
with lib.hm.gvariant;
let
  cfg = config.modules.gnome;
in
{
  options.modules.gnome = {
    enable = lib.mkEnableOption "Enable gnome settings";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs;[
      gnome-extension-manager
      gnome-shell-extensions
      gnome-extensions-cli
      dconf2nix
      dconf-editor

      gnomeExtensions.dash-to-dock
      gnomeExtensions.run-or-raise
      gnomeExtensions.clipboard-history
      gnomeExtensions.blur-my-shell
      gnomeExtensions.just-perfection
      gnomeExtensions.undecorate
      gnomeExtensions.switcher
      gnomeExtensions.kimpanel
      ];
    dconf.settings = {
      # dconf dump /org/gnome/ | dconf2nix 
      #-------------------------SHORTCUTS----------------------- 
      "org/gnome/desktop/wm/preferences"={
        num-workspaces=4;
      };
      "org/gnome/shell"={
        favorite-apps=[];
        disable-extension-version-validation=true;
      };
      "org/gnome/desktop/wm/keybindings"={
        close=["<Super>q"];
        switch-to-workspace-1=["<Super>1"];
        switch-to-workspace-2=["<Super>2"];
        switch-to-workspace-3=["<Super>3"];
        switch-to-workspace-4=["<Super>4"];
        toggle-maximized=["<Super>Up" "<Super><Alt><Ctrl>Up"];
        unmaximize=["<Super>Down" "<Super><Alt><Ctrl>Down"];
        show-desktop=["<Super>d"];
        minimize=["<Super>h"];
        always-on-top=["<Super>p"];
        cycle-windows=["<Super>bracketleft"];
        cycle-windows-backward=["<Super>bracketright"];
        begin-resize=["<Super>r"];
        begin-move=["<Super>m"];
        switch-input-source=["<Ctrl>space"];
        # switch-input-source=[""];
        switch-input-source-backward=[];
      };
      "org/gnome/shell/keybindings"={
        switch-to-application-1=[];
        switch-to-application-2=[];
        switch-to-application-3=[];
        switch-to-application-4=[];
        toggle-message-tray=[];
        toggle-overview=["<Ctrl>Up"];
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
        speed=0.2;
      };
      "org/gnome/desktop/peripherals/touchpad"={
        click-method="areas";
        speed=0.4;
      };
      "org/gnome/desktop/input-sources"={
        # xkb-options=["caps:hyper"];
        per-window=true;
        show-all-sources = true;
        sources = [ (mkTuple [ "xkb" "us" ]) (mkTuple [ "ibus" "Bamboo" ]) ];
      };
      "org/gnome/settings-daemon/plugins/power"={
        sleep-inactive-ac-type="nothing";
        sleep-inactive-battery-type="nothing";
        idle-dim=false;
      };
      # "org/gnome/desktop/background"={
      #   picture-uri-dark= builtins.toString ./. + "/background.jpg";
      # };
      "org/gnome/mutter"={
        experimental-features=["scale-monitor-framebuffer" "xwayland-native-scaling"];
        overlay-key="Super_L";
        dynamic-workspaces=false;
        workspaces-only-on-primary=false;
        edge-tiling=false;
      };
      "org/gnome/mutter/keybindings"={
        toggle-tiled-left=["<Super>Left" "<Super><Alt><Ctrl>Left"];
        toggle-tiled-right=["<Super>Right" "<Super><Alt><Ctrl>Right"];
      };

      # Turn off sharing
      "org/gnome/mutter/wayland"={
        xwayland-disable-extensions=["Xtest"];
      };
      "org/gnome/settings-daemon/plugins/media-keys"={
        screensaver = ["<Super><Alt>l"];
        logout = ["<Super><Alt><Shift>l"];
        shutdown = ["<Super><Atl><Shift>s"];
        reboot = ["<Super><Alt><Shift>r"];
        # suspend = ["<Super><Alt><Shift>"];
      };
      # dconf dump /org/gnome/shell/extensions/ | dconf2nix 
      #------------------------------EXTENSIONS---------------------
      "org/gnome/shell" = {
        enabled-extensions=[
          "run-or-raise@edvard.cz"
          "clipboard-history@alexsaveau.dev"
          "blur-my-shell@aunetx"
          "kimpanel@kde.org"
          "dash-to-dock@micxgx.gmail.com"
          "just-perfection-desktop@just-perfection"
          "undecorate@sun.wxg@gmail.com"
          "switcher@landau.fi"
          ];
      };
      "org/gnome/shell/extensions/just-perfection" = {
        panel=false;
        dask=false;
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
        toggle-menu=["<Alt>v"];
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
  };  
}
