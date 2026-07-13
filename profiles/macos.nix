# Shared by the two macOS hosts (macmini, airm3).
{lib, ...}: let
  on = lib.mkDefault true;
in {
  modules.home-manager = {
    base.macos.enable = on;
    environments.fonts.enable = on;
    dotfiles = {
      conda.enable = on;
      vscode.enable = on;
      terminal.kitty.enable = on;
      macos = {
        hammerspoon.enable = on;
        sleepwatcher.enable = on;
      };
    };
  };
}
