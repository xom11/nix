# Shared by every Linux host with a graphical session (a14, desktop, x1g6,
# vmware). Deliberately does NOT pick a window manager -- a14 runs sway+gnome,
# the others i3wm -- so each host still enables its own.
{lib, ...}: let
  on = lib.mkDefault true;
in {
  modules.home-manager = {
    environments = {
      fonts.enable = on;
      i18n.enable = on;
    };
    dotfiles = {
      rofi.enable = on;
      terminal.kitty.enable = on;
    };
  };
}
