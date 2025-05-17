{pkgs, lib, config, ...}:
{
  home.file."reboot.desktop" = {
    source = ./src/reboot.desktop;
    target = ".local/share/applications/reboot.desktop";
  };
  home.file."shutdown.desktop" = {
    source = ./src/shutdown.desktop;
    target = ".local/share/applications/shutdown.desktop";
  };
  home.file."suspend.desktop" = {
    source = ./src/suspend.desktop;
    target = ".local/share/applications/suspend.desktop";
  };
}