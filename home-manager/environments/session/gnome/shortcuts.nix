{
  "org/gnome/desktop/wm/preferences" = {
    num-workspaces = 4;
  };
  "org/gnome/desktop/wm/keybindings" = {
    close = ["<Super>q"];
    switch-to-workspace-1 = ["<Super>1"];
    switch-to-workspace-2 = ["<Super>2"];
    switch-to-workspace-3 = ["<Super>3"];
    switch-to-workspace-4 = ["<Super>4"];
    toggle-maximized = ["<Super>Up" "<Ctrl><Alt><Super>slash"];
    unmaximize = ["<Super>Down" "<Super><Alt><Ctrl>Down"];
    show-desktop = ["<Super>d"];
    minimize = ["<Super>h"];
    always-on-top = ["<Super>p"];
    cycle-windows = ["<Super>bracketleft"];
    cycle-windows-backward = ["<Super>bracketright"];
    begin-resize = ["<Super>r"];
    begin-move = ["<Super>m"];
    switch-input-source = ["<Ctrl>space"];
    # switch-input-source=[""];
    switch-input-source-backward = [];
  };
  "org/gnome/shell/keybindings" = {
    switch-to-application-1 = [];
    switch-to-application-2 = [];
    switch-to-application-3 = [];
    switch-to-application-4 = [];
    toggle-message-tray = [];
    toggle-overview = ["<Ctrl>Up"];
  };
  "org/gnome/shell/app-switcher" = {
    current-workspace-only = true;
  };
  "org/gnome/mutter" = {
    edge-tiling = true;
  };
  "org/gnome/mutter/keybindings" = {
    toggle-tiled-left = ["<Super>Left" "<Ctrl><Alt><Super>period"];
    toggle-tiled-right = ["<Super>Right" "<Ctrl><Alt><Super>comma"];
  };
  "org/gnome/settings-daemon/plugins/media-keys" = {
    screensaver = ["<Super><Alt>l"];
    logout = ["<Super><Alt><Shift>l"];
    shutdown = ["<Super><Alt><Shift>s"];
    reboot = ["<Super><Alt><Shift>r"];
    # suspend = ["<Super><Alt><Shift>"];
  };
}
