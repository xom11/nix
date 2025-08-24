{config, ...}:
{
  # home.sessionVariables = {
  #   XDG_SESSION_TYPE = "wayland";
  #   QT_QPA_PLATFORM = "wayland";
  #   ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  #   GDK_BACKEND = "wayland,x11";
  #   MOZ_ENABLE_WAYLAND = "1";
  #   _JAVA_AWT_WM_NONREPARENTING = "1";
  #   XDG_SCREENSHOTS_DIR = "$HOME/Pictures/Screenshots";
  #   NIXOS_OZONE_WL = 1; # fixed electron apps blurriness
  # };
  # home.file.".config/code-flags.conf".text = ''
  #   --enable-features=UseOzonePlatform
  #   --ozone-platform=wayland
  #   --enable-features=WaylandWindowDecorations
  # '';
}